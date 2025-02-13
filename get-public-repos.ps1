$token = GITHUB PAT"              # Replace with your GitHub Personal Access Token
$searchTerm = "MySearchTerm"	    #replace with your search term

$outputFile = "$MySearchTerm_GitHub_Public_Repos.csv"

$headers = @{ Accept = "application/vnd.github+json" }
if ($token -ne "") { $headers["Authorization"] = "Bearer $token" }

# Step 1: Search for all public GitHub organizations containing "csiro"
$searchUrl = "https://api.github.com/search/users?q=csiro+type:org&per_page=100"
$orgs = Invoke-RestMethod -Uri $searchUrl -Headers $headers

# Prepare output array
$repoData = @()

# Step 2: Loop through each found organization
foreach ($org in $orgs.items) {
    $orgName = $org.login
    Write-Output "Fetching repositories for org: $orgName"
    
    # Get all repositories for this organization
    $reposUrl = "https://api.github.com/orgs/$orgName/repos?per_page=100"
    $repos = Invoke-RestMethod -Uri $reposUrl -Headers $headers

    # Step 3: Loop through each repo
    foreach ($repo in $repos) {
        $repoName = $repo.name
        $repoURL = $repo.html_url

        # Format dates as YYYY-MM-DD
        $createdAt = [DateTime]::Parse($repo.created_at).ToString("yyyy-MM-dd")
        $lastUpdated = [DateTime]::Parse($repo.updated_at).ToString("yyyy-MM-dd")

        # Step 4: Check if GitHub Actions are enabled
        $actionsUrl = "https://api.github.com/repos/$orgName/$repoName/actions/workflows"
        try {
            $actionsResponse = Invoke-RestMethod -Uri $actionsUrl -Headers $headers
            $hasActions = if ($actionsResponse.total_count -gt 0) { "Yes" } else { "No" }
        } catch {
            $hasActions = "Error checking actions"
        }

        # Step 5: Get the last workflow run date
        $lastRunDate = "No Runs"
        if ($hasActions -eq "Yes") {
            $runsUrl = "https://api.github.com/repos/$orgName/$repoName/actions/runs?per_page=1"
            try {
                $runsResponse = Invoke-RestMethod -Uri $runsUrl -Headers $headers
                if ($runsResponse.total_count -gt 0) {
                    $lastRunDate = [DateTime]::Parse($runsResponse.workflow_runs[0].created_at).ToString("yyyy-MM-dd")
                }
            } catch {
                $lastRunDate = "Error fetching runs"
            }
        }

        # Store results
        $repoData += [PSCustomObject]@{
            Organization   = $orgName
            Repository     = $repoName
            URL           = $repoURL
            CreatedAt     = $createdAt
            LastUpdated   = $lastUpdated
            HasActions    = $hasActions
            LastActionRun = $lastRunDate
        }
    }
}

# Export to CSV
$repoData | Export-Csv -Path $outputFile -NoTypeInformation
Write-Output "Results saved to $outputFile"
