package demo.pools
{
	import demo.item.PersonItem;
	import demo.vo.PersonVO;

	public class PersonItemPool extends BasePool
	{
		public function PersonItemPool()
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
				return new PersonItem();
			}
		}
		
		override public function push(element:*):void
		{
			pool.push(element);
		}
	}
}