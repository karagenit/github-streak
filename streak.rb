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

data = Github.query(token, query)
dates = []
weeks = data['data']['viewer']['contributionsCollection']['contributionCalendar']['weeks']
weeks.each do |week|
  week['contributionDays'].each do |day|
    dates.push day
  end
end
dates.sort_by! { |h| Date.strptime(h['date'], "%Y-%m-%d") }
dates.reverse!
days = 0
dates.each do |date|
  if date['contributionCount'] > 0
    days += 1
  else
    break
  end
end
p days

mutation = %{
  changeUserStatus(input: { message: "Current Streak: #{days} Days", emoji: ":fire:" }) {
    clientMutationId
  }
}
