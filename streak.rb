require 'github/graphql'
require 'date'

token = IO.read('.token.txt').chomp

query = %{
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
}

# Get contribution calendar from github
data = Github.query(token, query)

# Grab just the data we care about (date/contrib pairs)
dates = []
weeks = data['data']['viewer']['contributionsCollection']['contributionCalendar']['weeks']
weeks.each do |week|
  week['contributionDays'].each do |day|
    dates.push day
  end
end

# Order contribs by date, most recent first
dates.sort_by! { |h| Date.strptime(h['date'], "%Y-%m-%d") }
dates.reverse!

# Count consecutive days with contribs > 0
days = 0
dates.each do |date|
  if date['contributionCount'] > 0
    days += 1
  else
    break
  end
end

# Set Github status based on streak
mutation = %{
  mutation {
    changeUserStatus(input: { message: "Current Streak: #{days} Days", emoji: ":fire:" }) {
      clientMutationId
    }
  }
}
Github.query(token, mutation)
