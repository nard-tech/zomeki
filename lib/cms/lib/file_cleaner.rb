class Cms::Lib::FileCleaner
  def self.clean_all(root=Rails.root.join('sites'))
    root = Pathname.new(root) if root.kind_of?(String)
    clean_files(root)
    clean_directories(root)
  end

  def self.clean_files(root=Rails.root.join('sites'))
    root = Pathname.new(root) if root.kind_of?(String)
    clean_feeds(root)
    clean_statics(root, 'r')
    clean_statics(root, 'mp3')
    clean_pagings(root)
    clean_attached_files(root)
    clean_maps(root)
  end

  def self.clean_directories(root=Rails.root.join('sites'))
    root = Pathname.new(root) if root.kind_of?(String)
    clean_empty_directories(root)
  end

  def self.clean_cms_nodes(site_id=nil)
    nodes = (if site_id
              Cms::Site.find(site_id).nodes
            else
              Cms::Node.reorder(:id)
            end).where(model: %w!Cms::Directory Cms::Page Cms::Sitemap!)
    nodes.each do |n|
      next if n.parent_id.zero? && n.model == 'Cms::Directory'
      begin
        [n.public_path, n.public_smart_phone_path].each do |path|
          next unless File.exist?(path)
          info_log "DELETED: #{path}"
          FileUtils.rm_rf path
        end
      rescue => e
        warn_log "Cms::Node(#{n.id}): #{e.message}"
      end
    end
  end

  private

  def self.clean_feeds(root)
    Dir[root.join('**/{feed,index}.{atom,rss}')].each do |file|
      info_log "DELETED: #{file}"
      File.delete file
    end
  end

  def self.clean_statics(root, base_ext)
    Dir[root.join("**/*.html.#{base_ext}")].each do |base_file|
      ['', '.r', '.mp3'].each do |ext|
        next unless File.exist?(file = base_file.sub(Regexp.new("\.#{base_ext}\z"), ext))
        info_log "DELETED: #{file}"
        File.delete file
      end
    end
  end

  def self.clean_pagings(root)
    Dir[root.join('**/*.p[0-9]*.html')].each do |base_file|
      info_log "DELETED: #{base_file}"
      File.delete base_file

      next unless File.exist?(file = base_file.sub(/\.p\d+\.html\z/, '.html'))
      info_log "DELETED: #{file}"
      File.delete file
    end
  end

  def self.clean_attached_files(root)
    Dir[root.join('**/file_contents')].each do |directory|
      info_log "DELETED: #{directory}"
      FileUtils.rm_rf directory
    end
  end

  def self.clean_maps(root)
    Dir[root.join('**/index_*@*.html')].each do |base_file|
      info_log "DELETED: #{base_file}"
      File.delete base_file

      next unless File.exist?(file = "#{File.dirname(base_file)}/index.html")
      info_log "DELETED: #{file}"
      File.delete file
    end
  end

  def self.clean_empty_directories(directory, delete_self: false)
    return unless directory.directory?
    directory.each_child do |child|
      clean_empty_directories(child, delete_self: true)
    end
    return unless directory.children.empty?
    info_log "DELETED: #{directory}"
    directory.delete if delete_self
  end
end
