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

# Skip current day if contribs = 0
dates.shift if dates[0]['contributionCount'] == 0

today = Date.strptime(dates[0]['date'], "%Y-%m-%d")
expiration = (today + 1).strftime("%Y-%m-%dT%H:%M:%S%z")

# Count current streak, consecutive days with contribs > 0
current = 0
dates.each do |date|
  if date['contributionCount'] > 0
    current += 1
  else
    break
  end
end

# Count best streak
best = 0
counter = 0
dates.each do |date|
  if date['contributionCount'] > 0
    counter += 1
  else
    counter = 0
  end
  best = counter if counter > best
end

# Set Github status based on streak
mutation = %{
  mutation {
    changeUserStatus(input: { message: "Current Streak: #{current} Days (Best: #{best} Days)", emoji: ":fire:", expiresAt: "#{expiration}" }) {
      clientMutationId
    }
  }
}
Github.query(token, mutation)

puts "Current Streak: #{current} Days (Best: #{best} Days)"
