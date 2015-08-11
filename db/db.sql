CREATE TABLE IF NOT EXISTS `user`(
    `uid` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
`username` varchar(255),
`passwd` varchar(512),
`role` integer
);