# encoding: utf-8
class BizCalendar::Content::Setting < Cms::ContentSetting
  set_config :month_number, :name => "index表示月数"
  set_config :show_month_number, :name => "拠点表示月数"
  set_config :date_style, name: "日付形式",
    comment: I18n.t('comments.date_style').html_safe
  set_config :time_style, name: "時間形式",
    comment: "<strong>午前/午後</strong>：%P <strong>時：</strong>%H <strong>分：</strong>%M <strong>秒：</strong>%S".html_safe
  
end