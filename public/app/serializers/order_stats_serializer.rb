class OrderStatsSerializer < ActiveModel::Serializer

  attributes :user_id,
            :today_count,
            :today_total,
            :today_change,
            :seven_day_count,
            :seven_day_total,
            :seven_day_change,
            :thirty_day_count,
            :thirty_day_total,
            :thirty_day_change,
            :thirty_day_profit

  def today_total
    s = "%.2f" % object.today_total
    "#{s}"
  end

  def seven_day_total
    s = "%.2f" % object.seven_day_total
    "#{s}"
  end

  def thirty_day_total
    s = "%.2f" % object.thirty_day_total
    "#{s}"
  end

  def thirty_day_profit
    s = "%.2f" % object.thirty_day_profit
    "#{s}"
  end

  def today_change
    if object.today_change.infinite? or object.today_change.nan?
      "0.0"
    else
      s = "%.1f" % object.today_change
      "#{s}"
    end
  end

  def seven_day_change
    if object.seven_day_change.infinite? or object.seven_day_change.nan?
      "0.0"
    else
      s = "%.1f" % object.seven_day_change
      "#{s}"
    end
  end

  def thirty_day_change
    if object.thirty_day_change.infinite? or object.thirty_day_change.nan?
      "0.0"
    else
      s = "%.1f" % object.thirty_day_change
      "#{s}"
    end
  end

end