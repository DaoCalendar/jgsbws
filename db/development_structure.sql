CREATE TABLE `leagues` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `predictions` (
  `id` int(11) NOT NULL auto_increment,
  `game_date_time` datetime default NULL,
  `league` int(11) default NULL,
  `week` int(11) default '0',
  `home_team_id` int(11) default NULL,
  `away_team_id` int(11) default NULL,
  `spread` float default NULL,
  `predicted_home_score` int(11) default '-1',
  `predicted_away_score` int(11) default '-1',
  `actual_home_score` int(11) default '-1',
  `actual_away_score` int(11) default '-1',
  `joe_guys_bet` int(11) default NULL,
  `joe_guys_bet_amount` int(11) default '10',
  `joe_guys_bet_amount_won` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `prob_home_win_su` float default '0',
  `prob_away_win_su` float default '0',
  `prob_push_su` float default '0',
  `prob_home_win_ats` float default '0',
  `prob_away_win_ats` float default '0',
  `prob_push_ats` float default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `teams` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `league_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_teams_league_id` (`league_id`),
  CONSTRAINT `fk_teams_league_id` FOREIGN KEY (`league_id`) REFERENCES `leagues` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `pw_reset_code` varchar(40) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (12)