class ManagerValidationHash < EstablishCompanyClientDbConnection

  enum kind: {
      GlobalConstant::ManagerValidationHash.reset_password_kind => 1,
      GlobalConstant::ManagerValidationHash.double_optin_kind => 2,
      GlobalConstant::ManagerValidationHash.manager_invite_kind => 3
  }

  enum status: {
      GlobalConstant::ManagerValidationHash.active_status => 1,
      GlobalConstant::ManagerValidationHash.blocked_status => 2,
      GlobalConstant::ManagerValidationHash.used_status => 3
  }

  def is_expired?
    (self.created_at.to_i + expiry_interval.to_i) < Time.now.to_i
  end

  def expiry_interval
    case self.kind
    when GlobalConstant::ManagerValidationHash.double_optin
      GlobalConstant::ManagerValidationHash.double_opt_in_expiry_interval
    when GlobalConstant::ManagerValidationHash.manager_invite_kind
      GlobalConstant::ManagerValidationHash.invite_in_expiry_interval
    when GlobalConstant::ManagerValidationHash.reset_password_kind
      GlobalConstant::ManagerValidationHash.reset_token_expiry_interval
    else
      fail "no expiry found for : #{self.kind}"
    end
  end

end
