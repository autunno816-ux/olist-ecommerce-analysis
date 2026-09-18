"""Render figures from reviewed SQL result tables. No metrics are calculated from images."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

BLUE = '#2563a6'
TEAL = '#11887d'
ORANGE = '#d86a36'
INK = '#173047'
SCOPE = 'Delivered orders | Full observed history, Sep 2016–Aug 2018'


def make_charts(t, output):
    for part in ('Q1', 'Q2', 'Q3'):
        (output / part).mkdir(parents=True, exist_ok=True)
    plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 11,
                         'axes.spines.top': False, 'axes.spines.right': False,
                         'axes.spines.left': False, 'axes.edgecolor': '#cfdae3',
                         'axes.labelcolor': INK, 'text.color': INK,
                         'xtick.color': INK, 'ytick.color': INK,
                         'figure.facecolor': 'white', 'axes.facecolor': 'white'})

    def save(fig, path, title, subtitle, footnote):
        fig.suptitle(title, x=.065, y=.97, ha='left', fontsize=19, fontweight='bold')
        fig.text(.065, .905, subtitle, ha='left', fontsize=10, color='#536a7c')
        fig.text(.065, .025, footnote + '\nSource: Olist public dataset · reviewed SQL results', fontsize=8, color='#536a7c')
        fig.tight_layout(rect=(.04,.105,.98,.87))
        fig.savefig(output / path, dpi=160, facecolor='white')
        plt.close(fig)

    def bars(rows, label, value, path, title, xlabel, subtitle=SCOPE, fmt='{:.2f}', color=BLUE, footnote=''):
        fig, ax = plt.subplots(figsize=(11,6.6))
        vals = [float(r[value]) for r in rows]
        labels = [str(r[label]).replace('_',' ') for r in rows]
        b = ax.barh(labels, vals, color=color, height=.64)
        ax.invert_yaxis()
        ax.set_xlim(0, max(vals)*1.22 if vals and max(vals) else 1)
        ax.bar_label(b, labels=[fmt.format(v) for v in vals], padding=7, fontsize=10)
        ax.set_xlabel(xlabel)
        ax.xaxis.grid(True, alpha=.17)
        ax.set_axisbelow(True)
        save(fig,path,title,subtitle,footnote or 'Each bar uses the population stated above.')

    monthly = t['q1_monthly']
    dates = [r['month'] for r in monthly]
    for key, title, ylabel, name in [
        ('order_count','Monthly delivered-order volume','Orders','monthly_orders.png'),
        ('revenue_brl','Monthly merchandise sales','Merchandise sales (BRL)','monthly_revenue.png'),
        ('mom_growth_pct','Revenue growth varies across months','Month-over-month change (%)','monthly_growth.png')]:
        fig, ax = plt.subplots(figsize=(11,6.6))
        vals = [float(r[key]) if r[key] is not None else float('nan') for r in monthly]
        ax.plot(dates, vals, marker='o', markersize=5, linewidth=2.4, color=BLUE)
        ax.set_ylabel(ylabel)
        ax.grid(axis='y', alpha=.18)
        if key != 'mom_growth_pct':
            ax.set_ylim(bottom=0)
            ax.yaxis.set_major_formatter(FuncFormatter(lambda x,p: f'{x:,.0f}'))
        else:
            ax.axhline(0, color='#9cadba', linewidth=.8)
        ax.set_xticks(dates[::3], [d.strftime('%b %Y') for d in dates[::3]])
        save(fig,'Q1/'+name,title,'Purchase months: Jan 2017–Aug 2018 | Delivered orders only',
             'Sales = item prices, excluding freight. January growth unavailable; late-period delivery outcomes may be censored.')
    bars(t['q1_states'], 'customer_state','revenue_share_pct','Q1/state_revenue.png',
         'Sales are concentrated in a few states','Share of all merchandise sales (%)',fmt='{:.2f}%',
         footnote='State is the customer location. All 27 states are shown.')
    bars(t['q1_categories'][:10], 'product_category','revenue_share_pct','Q1/category_revenue.png',
         'Top 10 product categories by sales','Share of all merchandise sales (%)',fmt='{:.2f}%',
         footnote='Denominator includes every category, including unclassified products; these bars do not sum to 100%.')

    seg = t['q2_customer_segments']
    rpt = next((r for r in seg if r['customer_type']=='Repeat'),
               {'customer_share_pct':0, 'order_share_pct':0, 'revenue_share_pct':0})
    for key,name,title,xlabel,fmt in [
        ('customer_share_pct','customer_share.png','Most observed customers purchase once','Share of purchasing customers (%)','{:.2f}%'),
        ('revenue_share_pct','revenue_share.png',f"Repeat customers contribute {float(rpt['revenue_share_pct']):.2f}% of sales",'Share of merchandise sales (%)','{:.2f}%'),
        ('revenue_brl','total_revenue.png','Sales by observed customer type','Merchandise sales (BRL)','{:,.2f}'),
        ('average_revenue_per_customer_brl','average_revenue.png','Repeat customers spend more across observed orders','Observed merchandise spend per customer (BRL)','{:,.2f}')]:
        bars(seg,'customer_type',key,'Q2/'+name,title,xlabel,fmt=fmt,color=TEAL,
             footnote='Repeat = at least two delivered orders per customer_unique_id. Observed spend is not lifetime value.')
    fig,ax = plt.subplots(figsize=(11,6.6))
    labels = ['Customer share','Order share','Revenue share']
    vals = [float(rpt[k]) for k in ('customer_share_pct','order_share_pct','revenue_share_pct')]
    b = ax.bar(labels,vals,color=[BLUE,'#7393ad',TEAL],width=.55)
    ax.bar_label(b,labels=[f'{v:.2f}%' for v in vals],padding=8,fontsize=13)
    ax.set_ylim(0,max(8,max(vals)*1.25))
    ax.set_ylabel('Share of the corresponding total (%)')
    ax.grid(axis='y',alpha=.18)
    ax.set_axisbelow(True)
    save(fig,'Q2/repeat_contribution.png','Repeat customers: separate people, orders and sales',SCOPE,
         'Each bar has a different denominator. This is descriptive segmentation, not a retention intervention effect.')
    bars(t['q2_quintiles'],'quintile','revenue_share_pct','Q2/revenue_quintiles.png',
         f"The highest-spending fifth generates {float(t['q2_quintiles'][0]['revenue_share_pct']):.2f}% of sales",'Share of merchandise sales (%)',fmt='{:.2f}%',color=TEAL,
         footnote='Quintile 1 = highest observed spend; groups are approximately equal in size. This is not a predictive segment.')
    bars(t['q2_repurchase'],'interval_bucket','customer_share_pct','Q2/repurchase_interval.png',
         'When observed repeat customers make a second purchase','Share of repeat customers (%)',fmt='{:.2f}%',color=TEAL,
         subtitle=f"First-to-second delivered purchase | {sum(r['customer_count'] for r in t['q2_repurchase']):,} observed repeat customers",
         footnote='Includes same-day purchases. Customers with no observed repeat are excluded; follow-up time varies.')

    overall = t['q3_overall'][0]
    bars([{'status':'On time','pct':100-float(overall['late_rate_pct'])},{'status':'Late','pct':overall['late_rate_pct']}],
         'status','pct','Q3/delivery_status.png','Most deliveries meet the estimated timestamp',
         'Share of eligible delivered orders (%)',fmt='{:.2f}%',color=TEAL,
         subtitle=f"Delivered orders with both delivery dates | n = {overall['order_count']:,}",
         footnote='Late = actual timestamp > estimated timestamp. Eight delivered orders lack actual delivery dates.')
    bars(t['q3_states'][:10],'customer_state','late_rate_pct','Q3/state_delays.png',
         'Delay rates differ across customer states','Late orders / eligible delivered orders (%)',fmt='{:.2f}%',color=ORANGE,
         footnote='Highest 10 timestamp-based delay rates. Denominators are available in q3_states.csv; some states have small samples.')
    fig, axes = plt.subplots(1,2,figsize=(12,6.6))
    rows = t['q3_states'][:10]
    for ax,key,color,xlabel in zip(axes,['average_delivery_days','late_rate_pct'],[BLUE,ORANGE],['Average delivery time (days)','Late-delivery rate (%)']):
        b=ax.barh([r['customer_state'] for r in rows],[float(r[key]) for r in rows],color=color)
        ax.invert_yaxis()
        ax.set_xlim(0,32)
        ax.bar_label(b,fmt='%.1f',padding=4,fontsize=9)
        ax.set_xlabel(xlabel)
        ax.grid(axis='x',alpha=.15)
        ax.set_axisbelow(True)
    save(fig,'Q3/state_time_and_delay.png','Delivery time and delay rate measure different things',SCOPE,
         'Same 10 states, ranked by delay rate. Separate axes preserve the units; states are not a time series.')
    rows=t['q3_state_reviews']
    fig,ax=plt.subplots(figsize=(11,6.6))
    ax.scatter([float(r['late_rate_pct']) for r in rows],[float(r['average_review_score']) for r in rows],
               s=[40+float(r['reviewed_order_count'])/180 for r in rows],color=TEAL,alpha=.75,edgecolors='white')
    offsets = {'SP':(5,8), 'MG':(-20,10), 'RJ':(-17,-15), 'BA':(5,7),
               'CE':(-15,-16), 'MA':(5,7), 'AL':(5,7)}
    for r in rows:
        if r['customer_state'] in offsets:
            ax.annotate(r['customer_state'],(float(r['late_rate_pct']),float(r['average_review_score'])),
                        xytext=offsets[r['customer_state']],textcoords='offset points',fontsize=9)
    ax.set_xlabel('Late-delivery rate among reviewed orders (%)')
    ax.set_ylabel('Mean order-level review score (1–5)')
    ax.set_ylim(1,5)
    ax.set_xlim(left=0)
    ax.grid(alpha=.15)
    save(fig,'Q3/state_reviews.png','States with more delays tend to have lower scores',
         '27 states | Eligible delivered orders with a review | Marker size reflects reviewed-order count',
         'Selected states labelled; all states in q3_state_reviews.csv. State-level association does not establish causality.')
    rows=t['q3_review_scores']
    fig,ax=plt.subplots(figsize=(11,6.6))
    vals=[float(r['average_review_score']) for r in rows]
    b=ax.bar([f"{r['delivery_status']}\nn = {r['reviewed_order_count']:,}" for r in rows],vals,color=[ORANGE,TEAL],width=.55)
    ax.bar_label(b,labels=[f'{v:.2f} / 5' for v in vals],padding=8,fontsize=14)
    ax.set_ylim(0,5)
    ax.set_ylabel('Mean order-level review score (1–5)')
    ax.grid(axis='y',alpha=.15)
    ax.set_axisbelow(True)
    save(fig,'Q3/review_scores.png','Late orders receive lower review scores',SCOPE,
         'Each reviewed order has equal weight. Descriptive comparison; product, seller and region may confound the relationship.')
