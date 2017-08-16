def verify_physicalpath
  if @resource[:physicalpath].nil? or @resource[:physicalpath].empty?
    fail "physicalpath is a required parameter"
  end
  if is_drive_path(@resource[:physicalpath])
    if ! File.exists?(@resource[:physicalpath])
      fail "physicalpath doesn't exist: #{@resource[:physicalpath]}"
    end    
  end
end

def verify_optional_physicalpath
  if @resource[:physicalpath].nil? or @resource[:physicalpath].empty?
    return
  end
  if is_drive_path(@resource[:physicalpath])
    if ! File.exists?(@resource[:physicalpath])
      fail "physicalpath doesn't exist: #{@resource[:physicalpath]}"
    end    
  end
end

def is_drive_path(path)
  return (path =~ /^.:(\/|\\)/)
end

def is_unc_path(path)
  return (path =~ /^\\\\[^\\]+\\[^\\]+/)
end
