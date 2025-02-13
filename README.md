# find-gh-public-repos

Powershell script to searches GitHub for public repos for a particular string, eg. "acme"

1. Generate a new token with repo and read:org permissions (public repo access should be enough).
2. Modify the code to add your search string and add a personal access token.
3. For each public repo found, it will return the following:

Organization, Repository, URL, Date created, Last updated, Actions present, Last Action run date.
 
note: If you dont supply a PAT, it will work anonymously but GitHub will likely block it as suspcious activity.
      If any orgs are SAML protected, then you will need to grant your token SSO to those orgs (if you are a member).
