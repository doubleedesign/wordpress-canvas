<{{ $tag }} @if($classes)@class($classes)@endif @attributes($attributes)>
	<span>{!! $content !!}</span>
	@if(isset($attributes['target']) && $attributes['target'] == '_blank')
		<i class="fa-solid fa-arrow-up-right-from-square"></i>
	@else
		<i class="fa-solid fa-arrow-right"></i>
	@endif
</{{ $tag }}>
