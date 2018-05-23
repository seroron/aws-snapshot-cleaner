require 'aws-sdk-ec2'
require 'optparse'

class AwsSnapshotCleaner
  def clean_snapshot(mode_remove: false,
                     filter_name: "",
                     filter_no_name: false)
    unless mode_remove
      puts "This is dry run mode."
    end
    
    ec2 = Aws::EC2::Client.new
    
    image_ids = ec2.describe_images(owners: ["self"]).images.map(&:image_id)
    
    ss = nil
    loop do
      attr = {owner_ids: ["self"]}
      attr[:next_token] = ss.next_token unless ss.nil?
      attr[:filters] = [{name: 'tag:Name', values:["*"+filter_name+"*"]}] unless filter_name.empty?
      
      ss = ec2.describe_snapshots(attr)
      ss.snapshots.each do |s|
        s.description.match(/Created by CreateImage\(.*?\) for (ami-.*?) /) do |md|
          ami_id = md[1]
          valid_snap = image_ids.include?(ami_id)

          unless valid_snap
            name = s.tags.select{|i| i.key=="Name"}.map(&:value).first.to_s
            next if filter_no_name && !name.empty?
            
            puts "#{s.snapshot_id} (Name:#{name} Size:#{s.size}GiB StartTime:#{s.start_time}) : #{ami_id} is deregistered"
              
            if mode_remove
              ec2.delete_snapshot({snapshot_id: s.snapshot_id})
            end
          end
        end
      end
      
      break if ss.next_token.nil?
    end
  end
end

if __FILE__ == $0
  opt = OptionParser.new

  args = {}
  opt.on('-r', '--remove', 'remove snapshot')  {|v| args[:mode_remove] = v}
  opt.on('--filter-name=NAME', 'list snapshots which name includes NAME') {|v| args[:filter_name] = v}
  opt.on('--filter-no-name',   'list unnamed snapshots') {|v| args[:filter_no_name] = v}
  opt.parse!(ARGV)
  
  AwsSnapshotCleaner.new.clean_snapshot(args)
end


