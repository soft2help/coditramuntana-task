module ReadOnly
  def use_read_only_databases
    ## implement logic to ensure read only database if you have a replica set or master-slave setup
    yield
  end
end
