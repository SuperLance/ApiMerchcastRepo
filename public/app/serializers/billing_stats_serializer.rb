class BillingStatsSerializer < ActiveModel::Serializer

  attributes :user_id,
             :this_month_count,
             :this_month_total,
             :last_month_count,
             :last_month_total

  def this_month_total
    s = "%.2f" % object.this_month_total
    "#{s}"
  end

  def last_month_total
    s = "%.2f" % object.last_month_total
    "#{s}"
  end

end