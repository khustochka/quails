class Hash

  def &(h2)
    delete_if { |k, v| v != h2[k] }
  end

end