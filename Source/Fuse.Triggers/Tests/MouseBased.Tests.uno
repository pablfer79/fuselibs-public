using Uno;
using Uno.Testing;
using Fuse;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Gestures;
using Fuse.Input;
using Fuse.Triggers;
using FuseTest;

namespace Fuse.Triggers.Test
{
	public class MouseBasedTests : TestBase
	{
		private TestRootPanel _root;

		public MouseBasedTests()
		{
			_root = new TestRootPanel();

			Fuse.Input.Pointer.RaiseMoved(_root, GetZeroPointerEventData());
			Fuse.Input.Pointer.RaiseReleased(_root, GetDefaultPointerEventData());
		}

		[Test]
		public void Hovering()
		{
			var setup = SetupHelper.Setup(_root, GetDummyButton(), new WhileHovering());

			Fuse.Input.Pointer.RaiseMoved(_root, GetDefaultPointerEventData());
			_root.PumpDeferred();
			Assert.AreEqual(1, setup.ForwardAction.PerformedCount);
			Assert.AreEqual(0, setup.BackwardAction.PerformedCount);
			
			Fuse.Input.Pointer.RaiseMoved(_root, GetOutsideOfControlsPointerEventData());
			_root.PumpDeferred();
			Assert.AreEqual(1, setup.ForwardAction.PerformedCount);
			Assert.AreEqual(1, setup.BackwardAction.PerformedCount);
		}

		[Test]
		public void WhilePressed()
		{
			var setup = SetupHelper.Setup(_root, GetDummyButton(), new WhilePressed());

			Fuse.Input.Pointer.RaisePressed(_root, GetDefaultPointerEventData());
			_root.PumpDeferred();
			Assert.AreEqual(1, setup.ForwardAction.PerformedCount);
			Assert.AreEqual(0, setup.BackwardAction.PerformedCount);
			
			Fuse.Input.Pointer.RaiseReleased(_root, GetDefaultPointerEventData());
			_root.PumpDeferred();
			Assert.AreEqual(1, setup.ForwardAction.PerformedCount);
			Assert.AreEqual(1, setup.BackwardAction.PerformedCount);
		}

		[Test]
		[Ignore("https://github.com/fusetools/fuselibs/issues/1751")]
		public void Tapped()
		{
			var setup = SetupHelper.Setup(_root, GetDummyButton(), new Tapped());

			//too long for tap
			Fuse.Input.Pointer.RaisePressed(_root, GetDefaultPointerEventData());
			_root.IncrementFrame(1);
			Fuse.Input.Pointer.RaiseReleased(_root, GetDefaultPointerEventData());
			_root.IncrementFrame(1);
			
			Assert.AreEqual(0, setup.ForwardAction.PerformedCount);
			Assert.AreEqual(0, setup.BackwardAction.PerformedCount);
			
			Fuse.Input.Pointer.RaisePressed(_root, GetDefaultPointerEventData());
			_root.IncrementFrame(0.05f);
			Fuse.Input.Pointer.RaiseReleased(_root, GetDefaultPointerEventData());

			Assert.AreEqual(1, setup.ForwardAction.PerformedCount);
			_root.IncrementFrame(0.001f); //backward not in same frame?
			Assert.AreEqual(1, setup.BackwardAction.PerformedCount);
		}

		[Test]
		public void Clicked()
		{
			var setup = SetupHelper.Setup(_root, GetDummyButton(), new Clicked());
			var setup2 = SetupHelper.AddAction(setup.Control, new DoubleClicked());

			Fuse.Input.Pointer.RaisePressed(_root, GetDefaultPointerEventData());
			_root.IncrementFrame(5); //no limit to click time
			Fuse.Input.Pointer.RaiseReleased(_root, GetDefaultPointerEventData());
			_root.PumpDeferred();

			Assert.AreEqual(1, setup.ForwardAction.PerformedCount);
			_root.IncrementFrame(0.001f); //backward not in same frame?
			Assert.AreEqual(1, setup.BackwardAction.PerformedCount);
			
			_root.IncrementFrame(0.1f);
			Fuse.Input.Pointer.RaisePressed(_root, GetDefaultPointerEventData());
			Fuse.Input.Pointer.RaiseReleased(_root, GetDefaultPointerEventData());
			_root.PumpDeferred();
			
			Assert.AreEqual(2, setup.ForwardAction.PerformedCount);
			Assert.AreEqual(1, setup2.ForwardAction.PerformedCount);
			_root.IncrementFrame(0.001f); //backward not in same frame?
			Assert.AreEqual(2, setup.BackwardAction.PerformedCount);
			Assert.AreEqual(1, setup2.BackwardAction.PerformedCount);
		}

		private Element GetDummyButton()
		{
			return new Button() 
						{ 
							Width = 100, 
							Height = 100, 
							HitTestMode = HitTestMode.LocalBounds | HitTestMode.Children 
						};
		}

		PointerEventData GetZeroPointerEventData()
		{
			return new PointerEventData
				{
					PointIndex = 1,
					WindowPoint = float2 (0),
					WheelDelta = float2 (0),
					WheelDeltaMode = Uno.Platform.WheelDeltaMode.DeltaPixel,
					IsPrimary = true,
					PointerType = Uno.Platform.PointerType.Mouse
				};
		}

		PointerEventData GetDefaultPointerEventData()
		{
			return new PointerEventData
				{
					PointIndex = 1,
					WindowPoint = float2 (50),
					WheelDelta = float2 (0),
					WheelDeltaMode = Uno.Platform.WheelDeltaMode.DeltaPixel,
					IsPrimary = true,
					PointerType = Uno.Platform.PointerType.Mouse
				};
		}

		PointerEventData GetOutsideOfControlsPointerEventData()
		{
			return new PointerEventData
				{
					PointIndex = 1,
					WindowPoint = float2 (500),
					WheelDelta = float2 (0),
					WheelDeltaMode = Uno.Platform.WheelDeltaMode.DeltaPixel,
					IsPrimary = true,
					PointerType = Uno.Platform.PointerType.Mouse
				};
		}
	}
}