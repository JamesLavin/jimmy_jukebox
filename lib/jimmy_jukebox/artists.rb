module Artists

  JAZZ_ARTISTS = {
  :at   => "art_tatum",
  :as   => "artie_shaw",
  :bg   => "benny_goodman",
  :bh   => "billie_holiday",
  :bb   => "bix_beiderbecke",
  :bm   => "bennie_moten",
  :cc   => "charlie_christian",
  :cp   => "charlie_parker",
  :cb   => "count_basie",
  :dg   => "dizzy_gillespie",
  :dr   => "django_reinhardt",
  :de   => "duke_ellington",
  :fh   => "fletcher_henderson",
  :jj   => "james_p_johnson",
  :jrm  => "jelly_roll_morton",
  :la   => "louis_armstrong",
  :lh   => "lionel_hampton",
  :odjb => "original_dixieland_jazz_band",
  :rn   => "red_norvo"
  }

  def key_to_subdir_name(key)
    value_to_subdir_name(JAZZ_ARTISTS[key.to_sym])
  end

  def value_to_subdir_name(value)
    return '/JAZZ/' + value.to_s.capitalize unless value.to_s.match(/_/)
    '/JAZZ/' + value.to_s.split("_").map! { |name_component| name_component.capitalize }.join("_")
  end

  def value_to_yaml_file(value)
    return value.to_s.capitalize unless value.to_s.match(/_/)
    value.to_s.split("_").map! { |name_component| name_component.capitalize }.join("") + '.yml'
  end


end
