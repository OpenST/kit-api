class GraphData < DbConnection::KitSaasSubenv

  enum graph_type: {
    GlobalConstant::GraphConstants.total_transactions => 1,
    GlobalConstant::GraphConstants.total_transactions_by_type => 2,
    GlobalConstant::GraphConstants.total_transactions_by_name => 3
  }

  enum duration_type: {
    GlobalConstant::GraphConstants.duration_type_day => 1,
    GlobalConstant::GraphConstants.duration_type_week => 2,
    GlobalConstant::GraphConstants.duration_type_month => 3,
    GlobalConstant::GraphConstants.duration_type_year => 4
  }

  serialize :data, JSON

end