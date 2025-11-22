cfg.houseTypes = {
    ['lowend'] = {
        searchables = {
            { coord = vec3(256.87, -995.48, -99.52) },
            { coord = vec3(266.24, -999.4, -99.29) },
            { coord = vec3(261.38, -1002.21, -99.53) },
            { coord = vec3(263.26, -1002.98, -99.5) },
            { coord = vec3(259.73, -1004.38, -98.93) },
        },
        collectables = {
            {
                model = `prop_boombox_01`,
                coord = vec3(263.357, -994.685, -98.803),
                item = 'stolen_boombox_01',
            },
            {
                model = `prop_micro_02`,
                coord = vec3(266.472, -994.724, -98.895),
                item = 'stolen_micro_02',
            },
            {
                model = `prop_kettle_01`,
                coord = vec3(264.072, -994.611, -98.986),
                item = 'stolen_kettle_01',
            },
            {
                model = `prop_toaster_02`,
                coord = vec3(266.670, -995.324, -99.039),
                item = 'stolen_toaster_02',
            },
            {
                model = `prop_vcr_01`,
                coord = vec3(256.668, -995.379, -99.315),
                item = 'stolen_vcr_01',
            },
            {
                model = `prop_tv_03`,
                coord = vec3(256.732, -995.448, -98.861),
                item = 'stolen_tv_03',
            },
            {
                model = `prop_tv_flat_03`,
                coord = vec3(262.689, -1001.848, -99.289),
                item = 'stolen_tv_flat_03',
            },
            {
                model = `prop_console_01`,
                coord = vec3(263.294, -1001.852, -99.304),
                item = 'stolen_console_01',
            },
            {
                model = `prop_mp3_dock`,
                coord = vec3(262.992, -1002.047, -99.573),
                item = 'stolen_mp3_dock',
            },
        },
        safe = {
            chance = 100, --chance of safe spawning
            coords = {
                desk = vec4(259.343994140625, -1003.6589965820312, -100.00900268554688, 90.0),
                safedoor = vec4(259.6411743164063, -1003.3812255859376, -99.1820831298828, 90.0),
                safebody = vec4(259.6409912109375, -1003.3809814453124, -99.18199920654295, 90.0),
                money = vec4(259.4159851074219, -1003.60400390625, -99.16500091552736, 0.0),
            },
        },
        resident = {
            chance = 100,
            model = `a_m_y_sunbathe_01`,
            coord = vec4(262.37, -1004.11, -98.26, 179.53),
            anim = {
                dict = 'timetable@tracy@sleep@',
                clip = 'base',
                flag = 1,
            },
        },
        exit = vec4(266.07, -1007.39, -101.96, 4.0),
        interior = {
            id = 149761,
            objects = {
                delete = {
                    {
                        model = `v_res_tt_cereal01`,
                        coord = vec3(266.569, -994.753, -98.588),
                    },
                    {
                        model = `v_res_fa_bread01`,
                        coord = vec3(266.426, -994.557, -98.574),
                    },
                },
            },
        },
    },
    ['midend'] = {
        searchables = {
            { coord = vec3(345.63, -1001.75, -99.25) },
            { coord = vec3(345.65, -995.14, -98.89) },
            { coord = vec3(341.42, -996.21, -99.66) },
            { coord = vec3(339.29, -1001.29, -99.46) },
            { coord = vec3(340.81, -1003.9, -98.75) },
            -- { coord = vec3(352.55, -998.88, -99.64) },
            { coord = vec3(348.79, -994.81, -99.33) },
            { coord = vec3(350.91, -993.24, -99.01) },
            { coord = vec3(346.95, -994.17, -99.51) },
        },
        collectables = {
            {
                model = `prop_tv_flat_01`,
                coord = vec3(337.28, -996.66, -99.02),
                item = 'stolen_tv_flat_01',
            },
            {
                model = `prop_tapeplayer_01`,
                coord = vec3(341.55, -1001.05, -99.04),
                item = 'stolen_tapeplayer_01',
            },
            {
                model = `v_club_vuhairdryer`,
                coord = vec3(350.94, -999.93, -99.25),
                item = 'stolen_hairdryer_01',
            },
            {
                model = `prop_micro_01`,
                coord = vec3(344.85, -1002.04, -99.15),
                item = 'stolen_micro_01',
            },
            {
                model = `prop_coffee_mac_02`,
                coord = vec3(342.76, -1004.02, -98.97),
                item = 'stolen_coffemac_02',
            },
            {
                model = `prop_toaster_01`,
                coord = vec3(341.75, -1004.01, -99.09),
                item = 'stolen_toaster_01',
            },
        },
        safe = {
            chance = 100, --chance of safe spawning
            coords = {
                desk = vec4(352.4302978515625, -994.4683227539064, -100.19304656982422, 270.0),
                safedoor = vec4(352.126, -994.695, -99.370, 270.0),
                safebody = vec4(352.1217041015625, -994.6981811523438, -99.36824798583984, 270.0),
                money = vec4(352.329, -994.468, -99.370, 0.0),
            },
        },
        resident = {
            chance = 100,
            model = `a_m_y_sunbathe_01`,
            coord = vec4(349.36, -996.12, -98.54, 266.78),
            anim = {
                dict = 'timetable@tracy@sleep@',
                clip = 'base',
                flag = 1,
            },
        },
        exit = vec4(346.54, -1013.21, -99.9, 2.84),
        interior = {
            id = 148225,
        },
    },
    ['highend'] = {
        searchables = {
            { coord = vec3(-1470.21, -528.85, 54.99) },
            { coord = vec3(-1468.22, -526.6, 55.98) },
            { coord = vec3(-1476.56, -530.31, 55.22) },
            { coord = vec3(-1470.03, -546.43, 55.41) },
            { coord = vec3(-1457.67, -536.48, 56.0) },
            { coord = vec3(-1457.29, -522.4, 53.22) },
            { coord = vec3(-1470.73, -535.13, 50.91) },
            { coord = vec3(-1474.14, -531.28, 50.22) },
            { coord = vec3(-1466.7, -538.83, 50.82) },
            { coord = vec3(-1468.6, -535.91, 50.98) },
        },
        collectables = {
            {
                model = `prop_laptop_01a`,
                coord = vec3(-1452.337, -527.926, 56.650),
                item = 'stolen_laptop_01a',
            },
            {
                model = `prop_tv_flat_01`,
                coord = vec3(-1479.17, -531.97, 55.743),
                item = 'stolen_tv_flat_01',
            },
            {
                model = `prop_t_telescope_01b`,
                coord = vec3(-1475.58, -539.85, 55.13),
                item = 'stolen_telescope_01',
            },
            {
                model = `v_res_tre_mixer`,
                coord = vec3(-1459.68, -532.81, 55.73),
                item = 'stolen_mixer_01',
            },
            {
                model = `v_res_m_kscales`,
                coord = vec3(-1460.26, -532.84, 55.53),
                item = 'stolen_kscales_01',
            },
            {
                model = `prop_printer_01`,
                coord = vec3(-1456.31, -534.51, 56.65),
                item = 'stolen_printer_01',
            },
            {
                model = `prop_monitor_w_large`,
                coord = vec3(-1451.23, -529.49, 56.65),
                item = 'stolen_monitor_01',
            },
            {
                model = `prop_monitor_w_large`,
                coord = vec3(-1450.96, -530.54, 56.65),
                item = 'stolen_monitor_01',
            },
            {
                model = `v_res_mm_audio`,
                coord = vec3(-1453.34, -526.57, 56.64),
                item = 'stolen_mmaudio_01',
            },
            {
                model = `v_res_mm_audio`,
                coord = vec3(-1468.31, -545.43, 55.47),
                item = 'stolen_mmaudio_01',
            },
        },
        safe = {
            chance = 100, --chance of safe spawning
            coords = {
                desk = vec4(-1469.22998046875, -538.5399780273438, 49.7216567993164, 125.0),
                safedoor = vec4(-1469.161, -538.190, 50.539, 125.0),
                safebody = vec4(-1469.1575927734, -538.18438720703, 50.544300079346, 125.0),
                money = vec4(-1469.2565917969, -538.50476074219, 50.56396484375, 125.0),
            },
        },
        resident = {
            chance = 100,
            model = `a_m_y_sunbathe_01`,
            coord = vec4(-1472.42, -532.14, 51.45, 301.85),
            anim = {
                dict = 'timetable@tracy@sleep@',
                clip = 'base',
                flag = 1,
            },
        },
        exit = vec4(-1457.96, -520.48, 55.92, 125.0),
        interior = {
            id = 145665,
            objects = {
                delete = {
                    {
                        model = `prop_player_phone_01`,
                        coord = vec3(-1453.456, -526.684, 56.736),
                    },
                    {
                        model = `prop_player_phone_01`,
                        coord = vec3(-1468.350, -545.379, 55.486),
                    },
                },
                create = {
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1456.967, -520.193, 55.7, -55.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1469.786, -524.510, 54.4, 35.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1473.096, -526.827, 54.4, 35.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1479.828, -536.122, 54.4, 125.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1476.105, -541.440, 54.4, 125.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1472.848, -546.090, 54.4, 125.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1469.770, -524.503, 49.6, 35.0),
                        doorFlag = true,
                    },
                    {
                        model = `v_ilev_bl_shutter2`,
                        coord = vec4(-1473.078, -526.819, 49.6, 35.0),
                        doorFlag = true,
                    },
                },
            },
        },
    },
}
