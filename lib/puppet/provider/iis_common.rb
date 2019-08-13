# verify if the given path is a local one
def is_local_path(path)
  (path =~ /^.:(\/|\\)/)
end

# verify if the given path is an UNC one
def is_unc_path(path)
  (path =~ %r{^\\\\[^\\]+\\[^\\]+})
end

# verify if the given path is a physicalpath
def verify_physicalpath
  if @resource[:physicalpath].nil? || @resource[:physicalpath].empty?
    raise('physicalpath is a required parameter')
  end
  if is_local_path(@resource[:physicalpath])
    unless File.exist?(@resource[:physicalpath])
      raise("physicalpath doesn't exist: #{@resource[:physicalpath]}")
    end
  end
end
