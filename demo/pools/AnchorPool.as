package demo.pools
{
	import demo.item.AnchorItem;
	import demo.vo.PersonVO;

	public class AnchorPool extends BasePool
	{
		public function AnchorPool()
		{
			super();
		}
		
		override public function pop():*
		{
			if(pool.length>0)
			{
				return pool.pop();
			}
			else
			{
				return new AnchorItem();
			}
		}
		
		override public function push(element:*):void
		{
			pool.push(element);
		}
	}
}