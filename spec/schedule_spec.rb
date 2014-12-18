RSpec.describe Biz::Schedule do
  let(:work_hours) {
    {
      mon: {'09:00' => '17:00'},
      tue: {'10:00' => '16:00'},
      wed: {'09:00' => '17:00'},
      thu: {'10:00' => '16:00'},
      fri: {'09:00' => '17:00'},
      sat: {'11:00' => '14:30'}
    }
  }
  let(:holidays)  { [Date.new(2006, 1, 1), Date.new(2006, 12, 25)] }
  let(:time_zone) { 'Etc/UTC' }

  subject(:schedule) {
    Biz::Schedule.new do |config|
      config.work_hours = work_hours
      config.holidays   = holidays
      config.time_zone  = time_zone
    end
  }

  describe "#periods" do
    it "returns a set of periods" do
      expect(schedule.periods).to be_a Biz::Periods
    end

    it "configures the periods to use the schedule" do
      expect(schedule.periods.schedule).to be schedule
    end
  end

  describe "#intervals" do
    it "returns the proper intervals" do
      expect(schedule.intervals).to eq [
        Biz::Interval.new(
          Biz::WeekTime.new(week_minute(wday: 1, hour: 9)),
          Biz::WeekTime.new(week_minute(wday: 1, hour: 17)),
          TZInfo::Timezone.get('Etc/UTC')
        ),
        Biz::Interval.new(
          Biz::WeekTime.new(week_minute(wday: 2, hour: 10)),
          Biz::WeekTime.new(week_minute(wday: 2, hour: 16)),
          TZInfo::Timezone.get('Etc/UTC')
        ),
        Biz::Interval.new(
          Biz::WeekTime.new(week_minute(wday: 3, hour: 9)),
          Biz::WeekTime.new(week_minute(wday: 3, hour: 17)),
          TZInfo::Timezone.get('Etc/UTC')
        ),
        Biz::Interval.new(
          Biz::WeekTime.new(week_minute(wday: 4, hour: 10)),
          Biz::WeekTime.new(week_minute(wday: 4, hour: 16)),
          TZInfo::Timezone.get('Etc/UTC')
        ),
        Biz::Interval.new(
          Biz::WeekTime.new(week_minute(wday: 5, hour: 9)),
          Biz::WeekTime.new(week_minute(wday: 5, hour: 17)),
          TZInfo::Timezone.get('Etc/UTC')
        ),
        Biz::Interval.new(
          Biz::WeekTime.new(week_minute(wday: 6, hour: 11)),
          Biz::WeekTime.new(week_minute(wday: 6, hour: 14, min: 30)),
          TZInfo::Timezone.get('Etc/UTC')
        )
      ]
    end

    context "when the weekdays are configured out of order" do
      let(:work_hours) {
        {
          tue: {'10:00' => '16:00'},
          mon: {'09:00' => '17:00'}
        }
      }

      it "returns the intervals in order" do
        expect(schedule.intervals).to eq [
          Biz::Interval.new(
            Biz::WeekTime.new(week_minute(wday: 1, hour: 9)),
            Biz::WeekTime.new(week_minute(wday: 1, hour: 17)),
            TZInfo::Timezone.get('Etc/UTC')
          ),
          Biz::Interval.new(
            Biz::WeekTime.new(week_minute(wday: 2, hour: 10)),
            Biz::WeekTime.new(week_minute(wday: 2, hour: 16)),
            TZInfo::Timezone.get('Etc/UTC')
          )
        ]
      end
    end
  end

  describe "#holidays" do
    it "returns the proper holidays" do
      expect(schedule.holidays).to eq [
        Biz::Holiday.new(
          Date.new(2006, 1, 1),
          TZInfo::Timezone.get('Etc/UTC')
        ),
        Biz::Holiday.new(
          Date.new(2006, 12, 25),
          TZInfo::Timezone.get('Etc/UTC')
        )
      ]
    end
  end

  describe "#time_zone" do
    it "returns the proper time zone object" do
      expect(schedule.time_zone).to eq TZInfo::Timezone.get('Etc/UTC')
    end
  end
end