<?php
namespace ideasonpurpose\CPT;

class Base
{
    protected $menu_index;
    /**
     * Default value for $menu_index is 21, "below Pages"
     * https://codex.wordpress.org/Function_Reference/register_post_type#menu_position
     *
     * @param integer $menu_index Used to position the item in admin menus
     */
    public function __construct($menu_index = 21)
    {
        $this->menu_index = $menu_index;

        if (WP_DEBUG) {
            add_action(
                'admin_menu',
                function () {
                    error_log("CPT: $this->type, index: $this->menu_index");
                },
                99
            );
        }

        add_action('init', [$this, 'define']);
        add_action('init', [$this, 'addQueryVars']);

        add_action('pre_get_posts', [$this, 'postsPerPage']);
    }

    public function filterByTaxonomy($slug)
    {
        global $typenow;
        if ($typenow === $this->type) {
            $tax = get_taxonomy($slug);
            if (!$tax) {
                return;
            }
            $terms = get_terms($slug);
            $terms = array_map(function ($term) use ($slug) {
                $template = '<option value="%s"%s>%s (%d)</option>';
                $selected = isset($_GET[$slug]) && $_GET[$slug] == $term->slug ? ' selected="selected"' : '';
                return sprintf($template, $term->slug, $selected, $term->name, $term->count);
            }, $terms);
            echo "<select name='$slug' id='$slug' class='postform'>";
            echo "<option value=''>All {$tax->label}</option>";
            echo implode("\n", $terms);
            echo "</select>";
        }
    }

    /**
     * Reference: https://codex.wordpress.org/Plugin_API/Action_Reference/pre_get_posts#Changing_the_number_of_posts_per_page.2C_by_post_type
     *
     * Assignment hierarchy for posts_per_page:
     *      1. $query->query['per_page']
     *      2. $query->query['posts_per_page']
     *      3. $this->posts_per_page
     *      4. get_option('posts_per_page')
     */
    public function postsPerPage($query)
    {
        if (
            !is_admin() &&
            !wp_is_json_request() &&
            isset($query->query_vars['post_type']) &&
            $query->query_vars['post_type'] == $this->type
        ) {
            $per_page =
                $query->query['per_page'] ??
                $query->query['posts_per_page'] ??
                $this->posts_per_page ??
                get_option('posts_per_page');
            $query->set('posts_per_page', $per_page);
        }
    }

    /**
     * Call this to remove the date menu for this CPT
     */
    public function removeDateMenu($disable, $post_type)
    {
        if ($post_type == $this->type) {
            return true;
        }
        return $disable;
    }

    /**
     * Add `per_page` query var for overriding posts_per_page from the url
     * NOTE: This overlaps with the wp-json query var
     */
    public function addQueryVars()
    {
        global $wp;
        $wp->add_query_var('per_page');
    }
}
