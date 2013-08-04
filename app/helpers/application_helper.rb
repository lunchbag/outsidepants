module ApplicationHelper

	def mark_as_claimed(item)
    item.claimed_status = true
  end

end
