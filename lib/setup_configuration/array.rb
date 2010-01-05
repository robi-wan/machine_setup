# encoding: utf-8

class Array
  # Splits _self_ in arrays with maximal size of _len_ and returns an array with this arrays.
  # :call-seq:
  #  array%(len) -> an_array of arrays
  #   [1,2,3,4,5,6] % 2 => [[1,2], [3,4], [5,6]]
  def % len
    inject([]) do |ary, x|
      ary << [] if [*ary.last].nitems % len == 0
      ary.last << x
      ary
    end
  end
end
