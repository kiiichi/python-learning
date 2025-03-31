env.test = function(event, NearbyGarroted, NearbyEnemies)
    aura_env.NearbyGarroted = NearbyGarroted
    aura_env.MissingGarrote = NearbyEnemies - NearbyGarroted
    return true
end