cfg.searchRewards = {
    ['lowend'] = {
        emptyChance = 10,
        itemCount = { 2, 3 }, -- buffed a bit so lowend isn't stingy
        items = {
            ['247_egobar']      = { label = 'Ego Bar', chance = 57, amount = 1 },
            ['water']           = { label = 'Bottle of Water', chance = 65, amount = 1 },
            -- light utility/cheap valuables
            ['bandage']       = { label = 'Bandage', chance = 45, amount = 1 },
            ['lockpick']      = { label = 'Lockpick', chance = 60, amount = 1 },
            ['electronickit'] = { label = 'Electronic Kit', chance = 38, amount = 1 },
            ['trojan_usb']    = { label = 'Trojan USB', chance = 35, amount = 1 },
            ['cryptostick']   = { label = 'Crypto Stick', chance = 25, amount = 1 },
            ['binoculars']    = { label = 'Binoculars', chance = 35, amount = 1 },
            ['ring']          = { label = 'Ring', chance = 24, amount = 1 },
            ['goldchain']     = { label = 'Golden Chain', chance = 14, amount = 1 },
            ['rolex']         = { label = 'Rolex', chance = 13, amount = 1 },
            ['emerald']       = { label = 'Emerald', chance = 10, amount = 1 },

            ['perc_10']        = { label = 'Perc 10', chance = 19, amount = {1,2} },
            ['perc_30']        = { label = 'Perc 30', chance = 20, amount = {1,2} },
            ['mdma']           = { label = 'Tesla Pill', chance = 15, amount = {1,2} },
            ['crisp_gelato']           = { label = 'Crisp Gelato Pack', chance = 40, amount = {1,2} },
            ['hary_payton']           = { label = 'Hary Payton Pack', chance = 40, amount = {1,2} },
        },
    },

    ['midend'] = {
        emptyChance = 9,
        itemCount = { 2, 3 },
        items = {
           ['247_egobar']      = { label = 'Ego Bar', chance = 65, amount = 1 },
            ['water']           = { label = 'Bottle of Water', chance = 60, amount = 1 },
            -- valuables/tools
            ['bandage']       = { label = 'Bandage', chance = 60, amount = 1 },
            ['lockpick']      = { label = 'Lockpick', chance = 62, amount = 1 },
            ['electronickit'] = { label = 'Electronic Kit', chance = 23, amount = 1 },
            ['trojan_usb']    = { label = 'Trojan USB', chance = 25, amount = 1 },
            ['cryptostick']   = { label = 'Crypto Stick', chance = 19, amount = 1 },
            ['binoculars']    = { label = 'Binoculars', chance = 18, amount = 1 },
            ['ring']          = { label = 'Ring', chance = 20, amount = 1 },
            ['goldchain']     = { label = 'Golden Chain', chance = 15, amount = 1 },
            ['rolex']         = { label = 'Rolex', chance = 13, amount = 1 },
            ['emerald']       = { label = 'Emerald', chance = 11, amount = 1 },

            ['perc_10']        = { label = 'Perc 10', chance = 19, amount = {1,2} },
            ['perc_30']        = { label = 'Perc 30', chance = 20, amount = {1,2} },
            ['mdma']           = { label = 'Tesla Pill', chance = 15, amount = {1,2} },
            ['crisp_gelato']           = { label = 'Crisp Gelato Pack', chance = 40, amount = {1,2} },
            ['hary_payton']           = { label = 'Hary Payton Pack', chance = 40, amount = {1,2} },
        },
    },

    ['highend'] = {
        emptyChance = 8,
        itemCount = { 2, 3 },
        items = {
            ['247_egobar']      = { label = 'Ego Bar', chance = 65, amount = 1 },
            ['water']           = { label = 'Bottle of Water', chance = 60, amount = 1 },
            ['247_cola_tonic']  = { label = 'Coke', chance = 65, amount = 1 },
            ['247_earthquaker'] = { label = 'Earth Quaker', chance = 65, amount = 1 },
            -- rare/illegal/high value
            ['bandage']       = { label = 'Bandage', chance = 60, amount = 1 },
            ['lockpick']      = { label = 'Lockpick', chance = 62, amount = 1 },
            ['electronickit'] = { label = 'Electronic Kit', chance = 23, amount = 1 },
            ['trojan_usb']    = { label = 'Trojan USB', chance = 25, amount = 1 },
            ['cryptostick']   = { label = 'Crypto Stick', chance = 26, amount = 1 },
            ['binoculars']    = { label = 'Binoculars', chance = 25, amount = 1 },
            ['ring']          = { label = 'Ring', chance = 23, amount = 1 },
            ['goldchain']     = { label = 'Golden Chain', chance = 19, amount = 1 },
            ['rolex']         = { label = 'Rolex', chance = 17, amount = 1 },
            ['emerald']       = { label = 'Emerald', chance = 19, amount = 1 },
            
            ['diamond']        = { label = 'Diamond', chance = 20, amount = 2 },
            ['perc_10']        = { label = 'Perc 10', chance = 19, amount = 2 },
            ['perc_30']        = { label = 'Perc 30', chance = 20, amount = 3 },
            ['actavis']        = { label = 'Actavis', chance = 16, amount = 2 },
            ['laptop']         = { label = 'Laptop', chance = 19, amount = 1 },
            ['msr']            = { label = 'Msr', chance = 18, amount = 1 },
            ['checkpaper']     = { label = 'Check Paper', chance = 20, amount = { 1, 3 } },
            ['blank']          = { label = 'Blank', chance = 18, amount = { 1, 3 } },
            ['printer']        = { label = 'Printer', chance = 17, amount = 1 },
            ['tris']           = { label = 'Tris', chance = 18, amount = { 1, 3 } },
            ['quagen']         = { label = 'Quagen', chance = 18, amount = 2 },
            ['yellow']         = { label = 'Yellow', chance = 18, amount = { 1, 2 } },
            ['oxycodone_10mg'] = { label = 'Oxycodone 10mg', chance = 18, amount = 1 },
            ['oxycodone_30mg'] = { label = 'Oxycodone 30mg', chance = 18, amount = 2 },
            ['mdma']           = { label = 'Tesla Pill', chance = 15, amount = 2 },
        },
    },
}

cfg.safeRewards = {
    emptyChance = 17,                  -- %
    itemCount = 1,                     -- number | table  -- {1, 10} = Random amount between 1 and 10
    items = {
        money = {                      -- do not change "money" text -- if you don't want money to come out, put it in the comment line
            type = 'cash',             -- 'cash', 'money', 'black_money'
            chance = 15,
            amount = 25000,            -- number | table  -- {1, 10} = Random amount between 1 and 10
        },
        ['black_money'] = {            -- do not change "money" text -- if you don't want money to come out, put it in the comment line
            label = 'Dirty Money',     -- 'cash', 'money', 'black_money'
            chance = 15,
            amount = 35000,            -- number | table  -- {1, 10} = Random amount between 1 and 10
        },
        ['WEAPON_CANIK']   = { label = 'Canik', chance = 2, amount = 1 },
        ['WEAPON_G26']   = { label = 'G26', chance = 1, amount = 1 },
        ['RUBY']   = { label = 'Ruby', chance = 12, amount = 1 },
    },
}

cfg.carriableItems = {
    ['stolen_micro_02'] = {
        model = `prop_micro_02`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            -- flag = 49,
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0063404518340349, -0.107253988783, -0.016921014068666),
            rot = vec3(0, 0, 0),
        },
    },
    ['stolen_vcr_01'] = {
        model = `prop_vcr_01`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(-0.017711621272042, -0.023799140492424, 0.011062572575624),
            rot = vec3(42.988364654139, -0.038868396109817, -1.3741033988058),
        },
    },
    ['stolen_tv_03'] = {
        model = `prop_tv_03`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0068133882765551, -0.26923079295446, 0.094674520289351),
            rot = vec3(33.451994038716, 0, 0),
        },
    },
    ['stolen_tv_flat_03'] = {
        model = `prop_tv_flat_03`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0, -0.10031812753771, -0.080695924752705),
            rot = vec3(-36.381890860157, 0, 0),
        },
    },
    ['stolen_console_01'] = {
        model = `prop_console_01`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0052793888123688, -0.039029825946311, -0.066810503055963),
            rot = vec3(33.524147525433, 0, 0),
        },
    },
    ['stolen_mp3_dock'] = {
        model = `prop_mp3_dock`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0087837071675949, -0.080335833480176, -0.10850030986718),
            rot = vec3(-1.8577946387754, 0, 0),
        },
    },
    ['stolen_kettle_01'] = {
        model = `prop_kettle_01`,
        placement = {
            bone = 28422,
            pos = vec3(0.24233163838244, -0.076910787800367, -0.075885094592554),
            rot = vec3(43.324080415683, -18.755255500489, 179.12572481256),
        },
    },
    ['stolen_toaster_01'] = {
        model = `prop_toaster_01`,
        placement = {
            bone = 28422,
            pos = vec3(0.2378402670754, -0.074801804514561, -0.019898325285959),
            rot = vec3(-95.280885660403, 7.0883151483302, 94.621716111995),
        },
    },
    ['stolen_toaster_02'] = {
        model = `prop_toaster_02`,
        placement = {
            bone = 28422,
            pos = vec3(0.2378402670754, -0.074801804514561, -0.019898325285959),
            rot = vec3(-95.280885660403, 7.0883151483302, 94.621716111995),
        },
    },
    ['stolen_boombox_01'] = {
        model = `prop_boombox_01`,
        placement = {
            bone = 28422,
            pos = vec3(0.22941293699841, 0.0046768200357765, -0.0482558869482),
            rot = vec3(-24.149280356908, -59.651434961567, 70.685257307293),
        },
    },
    ['stolen_laptop_01a'] = {
        model = `reh_prop_reh_laptop_01a`,
        placement = {
            bone = 28422,
            pos = vec3(0.062896867689233, 0.018684789966728, -0.044129701210051),
            rot = vec3(79.868767234006, -61.340532212356, 40.920106595931),
        },
    },
    ['stolen_tv_flat_01'] = {
        model = `prop_tv_flat_01`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0, -0.1280794435019, 0.0),
            rot = vec3(-10.522371226893, 0, 0),
        },
    },
    ['stolen_telescope_01'] = {
        model = `prop_t_telescope_01b`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.069877866731417, 0.030560775577089, -0.36213247796738),
            rot = vec3(60.977819952148, 60.704080178552, -94.416423269831),
        },
    },
    ['stolen_mixer_01'] = {
        model = `v_res_tre_mixer`,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.01209219900079, -0.082938890964221, 0.021882981710335),
            rot = vec3(0, 0, 77.126229240448),
        },
    },
    ['stolen_kscales_01'] = {
        model = `v_res_m_kscales`,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(-0.045520644482394, -0.066235495951816, -0.1843814431266),
            rot = vec3(5.5521037859531, -3.5152145562586, 89.900772201822),
        },
    },
    ['stolen_printer_01'] = {
        model = `prop_printer_01`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.002950702899625, -0.11225780171895, -0.17594187037278),
            rot = vec3(0, 0, 0),
        },
    },
    ['stolen_monitor_01'] = {
        model = `prop_monitor_w_large`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0, -0.064118627564016, -0.29704807124601),
            rot = vec3(0, 0, -4.724380419476),
        },
    },
    ['stolen_mmaudio_01'] = {
        model = `v_res_mm_audio`,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0087837071675949, -0.080335833480176, -0.20850030986718),
            rot = vec3(-1.8577946387754, 0, 0),
        },
    },
    ['stolen_tapeplayer_01'] = {
        model = `prop_tapeplayer_01`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0, -0.10031812753771, -0.080695924752705),
            rot = vec3(-36.381890860157, 0, 0),
        },
    },
    ['stolen_hairdryer_01'] = {
        model = `v_club_vuhairdryer`,
        placement = {
            bone = 28422,
            pos = vec3(0.2, 0.2, 0.0),
            rot = vec3(0.0, -0.0, 0.0),
        },
    },
    ['stolen_micro_01'] = {
        model = `prop_micro_01`,
        block = {
            running = true,
            jumping = true,
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.0063404518340349, -0.107253988783, -0.096921014068666),
            rot = vec3(0, 0, 0),
        },
    },
    ['stolen_coffemac_02'] = {
        model = `prop_coffee_mac_02`,
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        },
        placement = {
            bone = 28422,
            pos = vec3(0.021629391576425, -0.030711222032259, 0.05624671585963),
            rot = vec3(0, 0, 83.894662268879),
        },
    },
}
