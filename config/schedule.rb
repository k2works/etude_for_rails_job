# 出力先のログファイルの指定
set :output, 'log/crontab.log'

# 3時間毎に実行するスケジューリング
every 3.hours do
  #runner 'MyModel.some_process'
  #rake 'my:rake:task'
  #command '/usr/bin/my_great_command'
  #rake 'db:dump_all'
end
# 毎日 am10:00のスケジューリング
every 1.day, at: '10:00 am' do
  #rake 'db:reset'
end
# 一時間毎のスケジューリング
every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  #rake 'db:import_all'
end
# 金曜日のpm5時にスケジューリング
every :friday, at: '5pm' do # Use any day of the week or :weekend, :weekday
  #rake 'db:dump_clean'
end
# crontab型の設定「分」「時」「日」「月」「曜日」
# 毎月27日〜31日まで0:00に実行
every '0 0 27-31 * *' do
  #rake 'db:dump_all'
end

# 6-24時まで3時間おきに実行
work_hour_per_two = (6..24).select{ |_| _%3 == 0 }.map {|_| "#{_}:00" }
every 1.day, at: work_hour_per_two do
  #rake 'db:dump_all'
end

# 動作検証用(１分毎動作)
#every '*/1 * * * *' do
#  runner "Message.exec('Job validataion')"
#end
