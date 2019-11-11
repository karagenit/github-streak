# github-streak
Set Github Status to Current Contribution Streak

```
query {
  viewer {
		contributionsCollection {
      contributionCalendar {
        weeks {
          contributionDays {
            contributionCount
            date
          }
        }
      }
    }
  }
}
```

```
mutation {
  changeUserStatus(input:{message: "Current Streak: 0 Days", emoji:":fire:"}) {
    clientMutationId
  }
}
```
