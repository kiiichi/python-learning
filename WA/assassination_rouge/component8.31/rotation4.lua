env.test = function(event, NearbyRuptured, NearbyEnemies)
    aura_env.NearbyRuptured = NearbyRuptured
    aura_env.MissingRupture = NearbyEnemies - NearbyRuptured
    return true
end