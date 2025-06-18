
SMODS.Sprite:new("redd_atlas_j", Breaker.mod.path, "redd_jokers_atlas.png", 71, 95, "redd_atlas_j"):register()


SMODS.Joker {
    key = "redd_noise",
    loc_txt = {
        name = "Static Noise",
        text = {
            "Gains {X:mult,C:white} x0.5{} Mult if you",
            " {C:chips}Play{} or {C:red}Skip{} a {C:attention}Blind{}.",
            "Changes every blind",
            "Now {X:mult,C:white} x#1#{} Mult",
            "{C:inactive}Currently: #3#{}",
        }
    },
    config = { extra = { mult = 1, round_counted = false, type = "skip" } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.round_counted, card.ability.extra.type } }
    end,
    blueprint_compat = true,
    rarity = 3,
    atlas = "redd_atlas_j",
    pos = { x = 1, y = 0 },
    cost = 7,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.round_counted = true
            local available = { "play", "skip" }
            local chosen = pseudorandom_element(available, pseudoseed("asc_noise"))
            card.ability.extra.type = chosen
            message = "Now " .. chosen
            return { message = message, other_card = card }
        end

        if context.skip_blind and card.ability.extra.type == "skip" then
            card.ability.extra.mult = card.ability.extra.mult + 0.5
            card:juice_up(0.5, 0.5)

            local available = { "play", "skip" }
            local chosen = pseudorandom_element(available, pseudoseed("asc_noise"))
            card.ability.extra.type = chosen

            return { message = "X0.5", other_card = card }
        end

        if context.setting_blind and card.ability.extra.type == "play" then
            card.ability.extra.mult = card.ability.extra.mult + 0.5
            card:juice_up(0.5, 0.5)

            return { 
                message = "X0.5",
                other_card = card,
            }
        end

        if context.joker_main then
            local mult = card.ability.extra.mult or 1
            return {
                message = localize { type = "variable", key = "a_xmult", vars = { mult } },
                Xmult_mod = mult
            }
        end
    end,

    copying = function(self, card, from)
        card.ability.extra.mult = from.ability.extra.mult or 1
    end,

    set_badges = function(self, card, badges)
        badges[#badges + 1] = create_badge('Idea: Tisisrealnow', G.C.BLACK, G.C.WHITE, 0.9)
    end
}

SMODS.Joker {
    key = "redd_rot",
    loc_txt = {
        name = "Rule of Three",
        text = {
            "Rettrigger {C:attention}third{} played",
            "card. If it's a {C:attention}3{},",
            "rettriger it {C:attention}three{}",
            "times instead."
        }
    },
    rarity = 2,
    atlas = "redd_atlas_j",
    pos = { x = 1, y = 0 },
    cost = 4,


}

SMODS.Joker {
    key = "redd_square",
    loc_txt = {
        name = "Four Square",
        text = {
            "This joker gains {X:mult,C:white} x0.5{}",
            "Mult for every fourth",
            "{C:attention}4{} scored {C:inactive}(#1#/4){}",
            "{C:inactive}(Currently: {X:mult,C:white}x#2#{}){}",    
        }
    },
    config = { extra = { mult = 1, count = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.count, card.ability.extra.mult } }
    end,
    rarity = 2,
    atlas = "redd_atlas_j",
    pos = { x = 2, y = 0 },
    cost = 4,
}

SMODS.Joker {
    key = "redd_high_five",
    loc_txt = {
        name = "High Five",
        text = {
            "{X:mult,C:white} x5{} Mult if scored hand",
            "is a {C:attention}5 high card{}.",   
        }
    },
    rarity = 2,
    atlas = "redd_atlas_j",
    pos = { x = 0, y = 1 },
    cost = 4,
}

SMODS.Joker {
    key = "redd_six_figures",
    loc_txt = {
        name = "Six Figures",
        text = {
            "Played {C:attention}6{}s earn {C:gold}$2{} when",
            "scored.",   
        }
    },
    rarity = 2,
    atlas = "redd_atlas_j",
    pos = { x = 1, y = 1 },
    cost = 4,
    calculate = function(self, card, context) 
        if context.individual and context.cardarea == G.play then
			-- :get_id tests for the rank of the card. Other than 2-10, Jack is 11, Queen is 12, King is 13, and Ace is 14.
			if context.other_card:get_id() == 6 then
				-- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
				return {
                    
                    dollars = 2,
					card = context.other_card
				}
			end
		end
    end
}

SMODS.Joker {
    key = "redd_lucky_seven",
    loc_txt = {
        name = "Lucky Seven",
        text = {
            "Played {C:attention}7{}s become {C:attention}Lucky{}",
            "when scored.",   
        }
    },
    rarity = 2,
    atlas = "redd_atlas_j",
    pos = { x = 2, y = 1 },
    cost = 4,
    calculate = function(self, card, context) 
    if context.before and context.cardarea == G.play then
            local faces = {}
            for k, v in ipairs(context.scoring_hand) do
                if v:get_id() == 7 or trie then 
                    faces[#faces+1] = v
                    v:set_ability(G.P_CENTERS.m_lucky, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            return true
                        end
                    })) 
                end
            end
            if #faces > 0 then 
                return {
                    message = 'lucky',
                    colour = G.C.MONEY,
                    card = self
                }
            end
        end
    end
}