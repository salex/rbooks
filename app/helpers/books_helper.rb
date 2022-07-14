module BooksHelper
  def hash_to_struct(a_hash)
    # .to_struct is a monkey_patch to hash in config/initializer
    struct = a_hash.to_struct
    struct.members.each do |m|
      add_hash_to_struct(struct,m) if struct[m].is_a? Hash
    end
    struct 
  end

  def add_hash_to_struct(struct,member)
    struct[member] = hash_to_struct(struct[member])
  end

  def get_block(str,tag,from=0)
    tag_len = tag.length
    end_tag = tag.sub('<','</')
    tag_start = str.index(tag,from)

    return nil if tag_start.blank?
    tag_end = str.index(end_tag,tag_start+1)
    return nil if tag_end.blank?
    @block_end = tag_end+tag_len
    block = str[tag_start..tag_end+tag_len].strip
  end

  def get_block_list(str,tag)
    blocks = []
    @block = get_block(str,tag)
    while @block.present?
      blocks << @block
      @block = get_block(str,tag,@block_end)
    end

    puts blocks
  end

  def get_tag_attr(str,tag,from=0)
    end_tag = '<'
    tag_start = str.index(tag)
    return nil if tag_start.blank?
    tag_end = str.index(end_tag,tag_start+1)
    return nil if tag_end.blank?
    tag = str[tag_start..tag_end - 1].strip
  end

  def amt_to_pennies(amt)
    d,c = amt.split('.')
    puts "$ #{d} C #{c}"
    if c.present?
      if c.length == 1
        c = c+'0'
      elsif c.length > 2
        c = c[0..1]
      end
    else
      c = '00'
    end 
    pennies = (d+c).to_i 
  end
  # def add_array_members_to_struct(struct,array)
  #   struct[array].each_with_index do |elem,i|
  #     if elem.is_a? Hash
  #       struct[array][i.to_s] = hash_to_struct(elem)
  #     elsif elem.is_a? Array 
  #       puts "ARRAY #{elem}"
  #       struct[array][i.to_s] = add_array_members_to_struct(struct[array][i],elem)
  #     else
  #       struct[array][i] = elem
  #     end
  #   end
  # end
end
