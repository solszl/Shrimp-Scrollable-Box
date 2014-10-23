package demo.pools
{
	import com.shrimp.ext.scroll.util.pool.IPool;
	
	public class BasePool implements IPool
	{
		protected var pool:Array;
		public function BasePool()
		{
			pool = [];
		}
		
		public function alloc(size:int):void
		{
			throw new Error("not implement");
		}
		
		public function pop():*
		{
			return pool.pop();
		}
		
		public function push(element:*):void
		{
			pool.push(element);
		}
		
		public function dealloc():void
		{
			pool=[];
		}
		
		public function close():void
		{
			throw new Error("not implement");
		}
	}
}