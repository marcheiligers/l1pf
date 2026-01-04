# Remove duplicate elements from an array
# Translated from: https://github.com/mikolalysenko/uniq
#
# Parameters:
#   array - input array (will be modified)
#   comparator - optional comparison function
#
# Returns: array with duplicates removed (modifies input array)

def uniq(list, compare = nil) # TODO: does Ruby's standard library uniq handle this? and is it faster?
  return list if list.length == 0

  if compare
    # Sort with comparator
    list.sort! { |a, b| compare.call(a, b) }

    # Remove consecutive duplicates using comparator
    # compare returns truthy if elements are different
    ptr = 1
    len = list.length
    a = list[0]
    b = list[0]

    (1...len).each do |i| # TODO: convert to while loop for performance: i = 0; while (i += 1) < len
      b = a
      a = list[i]
      # In Ruby, 0 is truthy, so check for non-zero explicitly
      if compare.call(a, b) != 0  # If different
        if i == ptr
          ptr += 1
          next
        end
        list[ptr] = a
        ptr += 1
      end
    end

    list[0...ptr]
  else
    # Sort without comparator
    list.sort!

    # Remove consecutive duplicates using inequality
    ptr = 1
    len = list.length
    a = list[0]
    b = list[0]

    (1...len).each do |i| # TODO: convert to while loop for performance: i = 0; while (i += 1) < len
      b = a
      a = list[i]
      if a != b  # If different
        if i == ptr
          ptr += 1
          next
        end
        list[ptr] = a
        ptr += 1
      end
    end

    list[0...ptr]
  end
end
