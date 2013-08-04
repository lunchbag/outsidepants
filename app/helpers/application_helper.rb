module ApplicationHelper

	def mark_as_claimed(item)
    #puts item.claimed_status.to_s
    item.claimed_status = true
    item.save
  end

end
