<%@ page import="java.util.HashMap" %>
<%@ page pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<spring:eval expression="@environment.getProperty('server.type')"
	var="serverType" />
<spring:eval
	expression="@environment.getProperty('spring.datasource.url')"
	var="datasourceUrl" />
<spring:eval
	expression="@environment.getProperty('spring.datasource.username')"
	var="userName" />
<style>
.shine {
	background: black;
	/* background-image: linear-gradient(to right, #f6f7f8 0%, #edeef1 20%, #f6f7f8 40%, #f6f7f8 100%); */
	background-repeat: no-repeat;
	background-size: 400px 404px;
	display: inline-block;
	position: relative;
	-webkit-animation-duration: 1s;
	-webkit-animation-fill-mode: forwards;
	-webkit-animation-iteration-count: infinite;
	-webkit-animation-name: placeholderShimmer;
	-webkit-animation-timing-function: linear;
}

@
-webkit-keyframes placeholderShimmer {
	0% {
		background-position: -400px 0;
	}
	100% {
		background-position: 400px 0;
	}
}
</style>
<table class="table-help">
<colgroup>
	<col width="500px">
	<col width="">
	<col width="120px">
	<col width="100px">
</colgroup>
<tbody>
<td>
<h2>${page.menu_name }
	<c:if
		test="${pageContext.request.serverName eq 'localhost' or serverType eq 'dev'}">
		<span class="shine"
			style="background-image: linear-gradient(to left, violet, indigo, blue, green, yellow, orange, red); -webkit-background-clip: text; color: transparent;">
			${datasourceUrl.indexOf('124') > -1 ? '*운영으로 접속중*' : '개발'}
			${userName} </span>
		<span style="color: red"># ${serverType} # ${SecureUser.mem_no}
			# ${SecureUser.kor_name} # ${SecureUser.org_code} # ${SecureUser.org_name}</span>
	</c:if>
</h2>
</td>
<script type="text/javascript">
	$(document).ready(function() {
		$("#help_btn").prop("disabled", false);
		if (!window.opener){
			$("#main_form #popup_resize_button").hide()
		}
	});

	function goWindowOptionChange(){
		$M.goNextPageLayerDiv('open_layer_popup_option');
		// 간혹 페이지 내부에서 전체 비활성화 하는 경우 강제 변경
		$("#open_layer_popup_option input[disabled]").removeAttribute("disabled");
	}
	
	//도움말 페이지 이동
	function goHelpPopup() {
		var param = {
			"menu_seq" : "${page.menu_seq}"
		};
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=720, height=850, left=0, top=0";
		$M.goNextPage('/comp/comp0710', $M.toGetParam(param) , {popupStatus : poppupOption});
	}
</script>
<td>
<c:if test="${pageContext.request.serverName eq 'localhost' or serverType eq 'dev'}">&nbsp;&nbsp;${page.url }</c:if>
</td>
<td>
	<%-- 창 크기조절 2022.10.18 류성진 --%>
	<%-- menuMap[page.url] --%>
	<c:if test="${page.pop_yn eq 'Y' and page.add.POP_SIZE_ADJUST_YN eq 'Y'}">
		<button type="button" onclick="javascript:goWindowOptionChange()" class="btn btn-md btn-rounded btn-deepdark mr5"><i class="material-iconsphoto_size_select_small text-white mr3"></i> 팝업크기조정</button>
	</c:if>
</td>
<td>
<div align="right">
	<div style="margin-top:1px; margin-right:-5px">
	<c:if test="${page.help_yn eq 'Y' and page.has_help_yn eq 'N'}">
		<button type="button" class="btn btn-md btn-rounded btn-lightgray" id="help_btn" onclick="javascript:goHelpPopup()"><i class="material-iconshelp_outline text-white mr3"></i> 도움말 </button>
	</c:if>
	</div>

	<c:if test="${page.help_yn eq 'Y' and page.has_help_yn eq 'Y'}">
		<c:if test="${page.has_help_new eq 'Y'}">
			<div style="margin-top:-15px; margin-right:3px">
				<div style="margin-top:0px; pointer-events: none; width: 22px;position: relative;right:-10px;top: 15px;border-radius: 50%;background: #cc0000;opacity: 0.9;z-index:999;">
					<div class="btn btn-icon-md text-light">N</div>
				</div>
				<button type="button" class="btn btn-md btn-rounded btn-darkgray" id="help_btn" onclick="javascript:goHelpPopup()"><i class="material-iconshelp_outline text-white mr3"></i> 도움말 </button>
			</div>
		</c:if>
		<c:if test="${page.has_help_new eq 'N'}">
			<div style="margin-top:1px; margin-right:3px">
				<button type="button" class="btn btn-md btn-rounded btn-darkgray" id="help_btn" onclick="javascript:goHelpPopup()"><i class="material-iconshelp_outline text-white mr3"></i> 도움말 </button>
			</div>
		</c:if>
	</c:if>
</div>
</td>
</tbody>
</table>

<script>

	// $(window).on("resize", function() {
	// 	// window.innerWidth × window.innerHeight
	// 	// $("#s_reg_size_width").attr('placeholder',document.documentElement.clientWidth)
	// 	// $("#s_reg_size_height").attr('placeholder',document.documentElement.clientHeight)
	// 	$("#s_reg_size_width").attr('placeholder', window.innerWidth)
	// 	$("#s_reg_size_height").attr('placeholder', window.innerHeight)
	// });

	/**
	 * 팝업 닫침버튼
	 */
	function fnWindowOptionClose(){
		$.magnificPopup.close();
	}

	/**
	 * 팝업 저장
	 */
	function goWindowOptionPass(){
		var menu_seq = '${menuMap[page.url].menu_seq}';
		var size = {}

		var list = $("#open_layer_popup_option input");

		var options = [];
		for ( var i = 0; i < list.length; i++ ) {
			var item = $(list[i]);
			var max = item.attr("max");
			var name = item.attr("name");
			var value = item.val();
			if ( max && parseInt( max) < value) {
				console.log(max , value)
				return alert("수치가 너무 큽니다! 최대(" + max + ")");
			}
			options.push(name + '=' + value);

			if( ["width", "height"].indexOf(name) != -1){
				size[name] =value;
				size["old_" + name] = item.data("value");
				item.data("value", value);
			}
		}

		if ( size.width && size.height ){
			var x = size.width - size.old_width;
			var y = size.height - size.old_height;
			window.resizeBy(x,y);
			console.log(x,y);
		}

		console.log(options, size)

		var frm = $M.createForm();
		$M.setValue(frm, "pop_option", options.join(','));

		$M.goNextPageAjax("/comm/comm0102/" + menu_seq + "/popup", frm , { method : 'POST'},
				function(result) {
					if(result.success) {
						$.magnificPopup.close();
					}
				}
		);

	}
</script>

<!-- 팝업 크기 수정 모달 2022.10.19 -->
<div class="popup-wrap width-400 mfp-hide" style="margin-top: -250px;"  id="open_layer_popup_option" name="open_layer_popup_option" >
	<!-- 타이틀영역 -->
	<div class="main-title">
		<h2>팝업 옵션 변경</h2>
		<div onclick="javascript:fnWindowOptionClose();" class="mfp-close"><i class="material-iconsclose" ></i></div>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<div class="item-group">
			<div class="text-com font-13">팝업 옵션</div>
			<div class="form-group">
				<!-- 옵션 -->
				<%-- menuMap[page.url] --%>
				<!-- ${menuMap[page.url]} -->
				<c:forEach var="option" items="${menuMap[page.url].pop_option.split(',')}">
					<c:set var="item" value="${option.split('=')}" />
					<c:choose>
						<%-- 가로값 --%>
						<c:when test="${item[0].trim() eq 'width'}">
							<div class="form-row inline-pd">
								<label class="col-3 text-right col-form-label">가로</label>
								<div class="col-9">
									<div class="icon-btn-cancel-wrap">
										<input type="number" class="form-control" placeholder="${item[1]}" id="s_reg_size_width" name="${item[0].trim()}" required="required" alt="가로" data-value="${item[1].trim()}" value="${item[1].trim()}" max="1920">
									</div>
								</div>
							</div>
						</c:when>
						<%-- 세로값 --%>
						<c:when test="${item[0].trim() eq 'height'}">
							<div class="form-row inline-pd">
								<label class="col-3 text-right col-form-label">세로</label>
								<div class="col-9">
									<div class="icon-btn-cancel-wrap">
										<input type="number" class="form-control" placeholder="${item[1]}" id="s_reg_size_height" name="${item[0].trim()}" required="required" alt="세로" data-value="${item[1].trim()}" value="${item[1].trim()}" max="1200">
									</div>
								</div>
							</div>
						</c:when>
						<c:otherwise>
							<input type="hidden" class="form-control" placeholder="${item[1]}" name="${item[0].trim()}" value="${item[1]}">
						</c:otherwise>
					</c:choose>
				</c:forEach>
			</div>

			<div class="btn-group">
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 70px;" onclick="javascript:goWindowOptionPass()" id="savePass">저장</button>
					<button type="button" class="btn btn-info" style="width: 70px;" onclick="javascript:fnWindowOptionClose()">취소</button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 크기 수정 모달 -->
