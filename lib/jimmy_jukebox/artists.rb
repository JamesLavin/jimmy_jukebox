module Artists

  ARTISTS = {
    acb:  { genre: 'BANJO', name: "archibald_camp_banjo" },
    at:   { genre: 'JAZZ', name: "art_tatum" },
    as:   { genre: 'JAZZ', name: "artie_shaw"},
    bg:   { genre: 'JAZZ', name: "benny_goodman"},
    bh:   { genre: 'JAZZ', name: "billie_holiday"},
    bb:   { genre: 'JAZZ', name: "bix_beiderbecke"},
    bm:   { genre: 'JAZZ', name: "bennie_moten"},
    c:    { genre: 'CLASSICAL', name: "chopin"},
    cc:   { genre: 'JAZZ', name: "charlie_christian"},
    cp:   { genre: 'JAZZ', name: "charlie_parker"},
    ch:   { genre: 'JAZZ', name: "coleman_hawkins"},
    chjb: { genre: 'JAZZ', name: "clifford_hayes_jug_blowers"},
    cb:   { genre: 'JAZZ', name: "count_basie"},
    dx:   { genre: 'JAZZ', name: "dixieland"},
    dg:   { genre: 'JAZZ', name: "dizzy_gillespie"},
    dr:   { genre: 'JAZZ', name: "django_reinhardt"},
    de:   { genre: 'JAZZ', name: "duke_ellington"},
    eh:   { genre: 'JAZZ', name: "earl_hines"},
    fh:   { genre: 'JAZZ', name: "fletcher_henderson"},
    h:    { genre: 'CLASSICAL', name: 'haydn'},
    jj:   { genre: 'JAZZ', name: "james_p_johnson"},
    jrm:  { genre: 'JAZZ', name: "jelly_roll_morton"},
    ko:   { genre: 'JAZZ', name: "king_oliver"},
    la:   { genre: 'JAZZ', name: "louis_armstrong"},
    lh:   { genre: 'JAZZ', name: "lionel_hampton"},
    lvb:  { genre: 'CLASSICAL', name: "beethoven"},
    m:    { genre: 'CLASSICAL', name: "mendelssohn"},
    md:   { genre: 'JAZZ', name: "miles_davis"},
    odjb: { genre: 'JAZZ', name: "original_dixieland_jazz_band"},
    rt:   { genre: 'JAZZ', name: "ragtime"},
    rn:   { genre: 'JAZZ', name: "red_norvo"},
    fs:   { genre: 'CLASSICAL', name: "franz_schubert"},
    sb:   { genre: 'JAZZ', name: "sidney_bechet"},
    wam:  { genre: 'CLASSICAL', name: "mozart"}
  }

  def artist_genre(key)
    ARTISTS[key][:genre]
  end

  def artist_name(key)
    ARTISTS[key][:name]
  end

  def artist_name_to_genre(name)
    p "looking for #{name}"
    artists = ARTISTS.select { |k,v| v[:name] == name }
    p artists
    key, value = artists.first
    value[:genre]
  end

  def artist_name_to_subdir_name(name)
    return "/#{artist_name_to_genre(name)}/" + name.to_s.capitalize unless name.to_s.match(/_/)
    "/#{artist_name_to_genre(name)}/" + name.to_s.split("_").map! { |name_component| name_component.capitalize }.join("_")
  end

  def artist_key_to_subdir_name(key)
    artist_name_to_subdir_name(artist_name(key))
  end

  def artist_key_to_yaml_file(key)
    artist_name_to_yaml_file(artist_name(key))
  end

  def artist_name_to_yaml_file(name)
    return name.to_s.capitalize + '.yml' unless name.to_s.match(/_/)
    name.to_s.split("_").map! { |name_component| name_component.capitalize }.join("") + '.yml'
  end

end
