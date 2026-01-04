<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'vanilla_dev' );

/** Database username */
define( 'DB_USER', 'root' );

/** Database password */
define( 'DB_PASSWORD', '' );

/** Database hostname */
define( 'DB_HOST', 'localhost:3309' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'gfd+#T:6JF_ldLNs:HEFBkgO Ei/J6E_b &*5vqy,cc,zCpT*H7yEfhc.C%w=4R;' );
define( 'SECURE_AUTH_KEY',  '+fyrq*Q9hX%nc9!R-U@^v<TU7~O.:@W0[GpJws;OMajd|eGC Fp`L#`p,tqrUnkK' );
define( 'LOGGED_IN_KEY',    'y0c0y|0jZ9E5K]8w)z2uB`BXx}hz=JOn(PHND2^Ee7m-h}`DcyEuuD]?aTWJ+pvV' );
define( 'NONCE_KEY',        'jVBgMHyMaax2ad>)z#PUCQ-XA9~s3d7~,{Ab?(b/L|oi3]HM7p[NF*BvCk]+{o,^' );
define( 'AUTH_SALT',        'OlVk 7efY)fC}ZQtwblnbQfHD^$Z-+i<)XV}UXpCmf(Olj0X`q_6q6f_BbZ!C.>g' );
define( 'SECURE_AUTH_SALT', 'Y0[)XYN!=1+t.U|Ov7[b{`QS45v(IR<pNs1~/e>LQ:!&B?*Tzd#M+8u>=}=XqG$k' );
define( 'LOGGED_IN_SALT',   '`+]2m[A2Z+1y_*l5=ocQ}|^V`43MdU;?=?djS4uCx_c#0&$NJE8W%W. vm*{$=~t' );
define( 'NONCE_SALT',       ':/+41,<Z_|6|S]xG@S(~D-@HHTVmPkb+]qRvt7To:S.pTVM,.@pH(NuT-.C]E.Q!' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', false );
define( 'SCRIPT_DEBUG', false ); // NOTE: Blocks that use VueJS cause React errors when this is enabled, so only enable it when actively using it for other things

define( 'WP_ENVIRONMENT_TYPE', 'local' );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
