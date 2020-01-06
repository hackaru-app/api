# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  add_template_helper(DurationHelper)

  def report(user, title, range)
    @title = title
    @report = build_report(user, range)
    mail(subject: @title, to: user.email)
  end

  private

  def build_report(user, range)
    report = Report.new(
      user: user,
      start_date: range.begin,
      end_date: range.end,
      time_zone: 'UTC' # TODO
    )
    report.valid!
    report
  end
end
