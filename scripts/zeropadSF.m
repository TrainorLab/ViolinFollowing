function specflux = zeropadSF(specflux_raw, desiredLen)
  lenDiff = desiredLen - length(specflux_raw);
  if lenDiff==0
    specflux = speflux_raw;
  elseif lenDiff>0;
    specflux = [specflux_raw; repmat(0, lenDiff, 1)];
  else
    specflux = specflux_raw(end-lenDiff);
  end
end