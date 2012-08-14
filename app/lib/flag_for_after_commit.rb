module FlagForAfterCommit

  def flag_for_after_commit(key)
    @flags_for_after_commit ||= {}
    @flags_for_after_commit[flag_for_after_commit_key(key)] = true
  end

  def delete_after_commit_flag(key)
    @flags_for_after_commit ||= {}
    @flags_for_after_commit.delete(flag_for_after_commit_key(key))
  end

  alias_method :flagged_for_after_commit?, :delete_after_commit_flag

  private
  def flag_for_after_commit_key(key)
    "#{self.class.to_s.downcase}:#{key}"
  end
end