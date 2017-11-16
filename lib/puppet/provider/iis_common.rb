def is_local_path(path)
  return (path =~ /^.:(\/|\\)/)
end

def is_unc_path(path)
  return (path =~ /^\\\\[^\\]+\\[^\\]+/)
end

def verify_physicalpath
  if @resource[:physicalpath].nil? or @resource[:physicalpath].empty?
    fail("physicalpath is a required parameter")
  end
  if is_local_path(@resource[:physicalpath])
    if ! File.exists?(@resource[:physicalpath])
      fail("physicalpath doesn't exist: #{@resource[:physicalpath]}")
    end    
  end
end
