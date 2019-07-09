def local_path(path)
  (path =~ %r{/^.:(\/|\\)/})
end

def unc_path(path)
  (path =~ %r{^\\\\[^\\]+\\[^\\]+})
end

def verify_physicalpath
  if @resource[:physicalpath].nil? || @resource[:physicalpath].empty?
    raise('physicalpath is a required parameter')
  end
  if local_path?(@resource[:physicalpath])
    unless File.exist?(@resource[:physicalpath])
      raise("physicalpath doesn't exist: #{@resource[:physicalpath]}")
    end
  end
end
