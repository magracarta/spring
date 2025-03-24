<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 모바일관리 > 기준정보 > 버튼관리 > null > null
-- 작성자 : 김태훈 (전호형)
-- 최초 작성일 : 2019-12-19 14:23:48 (2023-01-31)
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<link rel="stylesheet" type="text/css" href="/static/css/mApi/css/yk-tablet.css" />
	<script type="text/javascript">
	
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		
		$(document).ready(function() {
			createAUIGrid();
			fnNew();
			// $( ".iclassYn" ).change(function() {
			// 	fnStateChange(this.value);
			// });
			$( "#size_class, #btn_class" ).change(function() {
				if ($M.getValue("size_class") != "" && $M.getValue("btn_class") != "") {
					fnPreview();
				} else {
					$("#preview").html("");
				}
			});
		});	
		
		function fnSearch(successFunc) {
			var param = {
					"s_btn_name" : $M.getValue("s_btn_name"),
					"s_js_name" : $M.getValue("s_js_name"),
					"s_use_yn" : $M.getValue("s_use_yn"),
					"page" : page,
					"rows" : s_rows
			}
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}
		
		// 조회
		function goSearch(isNew) { 
			page = 1;
			moreFlag = "N";
			if (isNew != undefined) {
				fnNew();				
			}
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		function enter(fieldObj) {
			var field = [ "s_btn_name", "s_js_name" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 미리보기
		function fnPreview() {
			var htmlArr = []; // pre, post fix
			var btn = "<button type='button' id='_"+$M.getValue("js_name")+"' class='"+$M.getValue("size_class")+" "+$M.getValue("btn_class")+"' #javascript#>";
			// if ($M.getValue("i_class") != "" && $M.getValue("icon_btn_yn") == "Y"){
			// 	btn = btn + "<i class='"+$M.getValue("i_class")+"'></i>"
			// };
			// 미리보기 자바스크립트 실행 막기
			$("#preview").html(btn+$M.getValue("btn_name")+"</button>");
			btn = btn.replace("#javascript#", "onclick='javascript:"+$M.getValue("js_name")+"();'");
			htmlArr.push(btn); // pre
			htmlArr.push("</button>"); // post
			return htmlArr;
		}
		
		// 아이콘버튼 N일 경우 아이콘클래스 입력 막기
		// function fnStateChange(value) {
		// 	if (value == 'Y'){
		// 		$('#i_class').prop('disabled', false);
		// 	} else {
		// 		$M.setValue("i_class", "");
		// 		$('#i_class').prop('disabled', 'disabled');
		// 	};
		// }
		
		// 신규
		function fnNew() {
			var frm = document.main_form;
			
			var param = {
					cmd : "C",
					btn_name : "",
					size_class : "",
					btn_class : "",
					js_name : "",
					use_yn : "Y",
					remark : "",
					icon_btn_yn : "N",
					appr_yn : "N",
					m_btn_seq : ""
			}
			$M.setValue(param);
			$("#btn_name").focus();
			// fnStateChange($M.getValue("icon_btn_yn"));
			$("#preview").html("");
		}
		
		// 저장
		function goSave() {
			var frm = document.main_form;
			if($M.validation(document.main_form, {field:['btn_name', 'size_class', 'btn_class', 'js_name', 'icon_btn_yn', 'use_yn']}) == false) {
				return;
			}
			// if ($M.getValue("icon_btn_yn") == "Y" && $M.getValue("i_class") == ""){
			// 	alert("아이콘버튼을 사용할 경우, 아이콘 클래스를 지정하세요.");
			// 	return;
			// }
			$M.setValue("html_prefix",fnPreview()[0]);
			$M.setValue("html_postfix",fnPreview()[1]);
			// cmd가 C일 경우 등록

			if ($M.getValue(frm, "cmd") == "C"){
				$M.goNextPageAjaxSave(this_page, frm , { method : 'POST'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);		
							//fnNew();
							goSearch();
						};
					}
				);
			// cmd가 C가 아니면 수정
			} else {
				goUpdate(frm);
			};
		}
		
		// 수정
		function goUpdate(frm) {
			$M.goNextPageAjaxSave(this_page+"/"+$M.getValue("m_btn_seq"), frm , { method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);		
						//fnNew();
						goSearch();
					};
				}
			);
		}
		
		// 메인그리드
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "m_btn_seq",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				height : "420"
			};
			var columnLayout = [
				{ 
					headerText : "버튼명", 
					dataField : "btn_name", 
					width : "25%", 
					style : "aui-left aui-link",
					editable : false
				}, 
				{ 
					headerText : "아이콘유무", 
					dataField : "icon_btn_yn", 
					width : "10%", 
					style : "aui-center",
					editable : false,
					visible : false
				}, 
				{ 
					headerText : "js 명령어", 
					dataField : "js_name", 
					width : "20%", 
					style : "aui-left",
					editable : false
				}, 
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "10%", 
					style : "aui-center",
					editable : false
				}, 
				{ 
					headerText : "사용 메뉴수", 
					dataField : "menu_cnt", 
					width : "15%", 
					style : "aui-right",
					editable : false
				}, 
				{ 
					headerText : "비고", 
					dataField : "remark", 
					style : "aui-left",
					editable : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				var frm = document.main_form;
				$M.setValue(frm, "cmd", "U");
				var param = {
					"m_btn_seq" : event.item["m_btn_seq"]
				}
				goSearchDetail(param);          
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		function fnScollChangeHandelr(event) {
			// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
			if(event.position == event.maxPosition && moreFlag == "Y") {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);								
				};
			});
		}
		
		// 상세 조회		
		function goSearchDetail(param) {
			console.log(param);
			//param값 없으면 return
			if(param ==null) {
				return;
			};
			$M.goNextPageAjax(this_page + "/" + param.m_btn_seq, '', '',
				function(result) {
					if(result.success) {
						var row = result.detail;
						$M.setValue(row);
						// fnStateChange(row.icon_btn_yn);
						fnPreview();
					};
				}
			);
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="130px">
								<col width="70px">
								<col width="130px">
								<col width="70px">
								<col width="130px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>
									<th>버튼명</th>
									<td>
										<input type="text" class="form-control" id="s_btn_name" name="s_btn_name">
									</td>							
									<th>JS명령어</th>
									<td>
										<input type="text" class="form-control" id="s_js_name" name="s_js_name">
									</td>	
									<th>사용여부</th>
									<td>
										<select class="form-control" id="s_use_yn" name="s_use_yn">
											<option value="">- 전체 -</option>
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch('new');">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->	
					<div class="row">
						<!-- 버튼목록 -->
						<div class="col-6">
							<div class="title-wrap mt10">
								<h4>버튼목록</h4>		
							</div>
							<div style="margin-top: 5px;" id="auiGrid"></div>
							<!-- 그리드 서머리, 컨트롤 영역 -->
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="total_cnt">0</strong>건 
								</div>						
							</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
						</div>
						<!-- /버튼목록 -->						
						<div class="col-6">
							<div class="row">
								<!-- 버튼정보 -->								
								<div class="col-12" style="padding-left : 10px;">
									<div class="title-wrap mt10">
										<h4>버튼정보</h4>					
									</div>							
									<!-- 폼테이블 -->	
									<div>
										<table class="table-border mt5">
											<colgroup>
												<col width="100px">
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right essential-item">버튼명</th>
													<td>
														<input type="text" class="form-control essential-bg" id="btn_name" name="btn_name" alt="버튼명">
													</td>
												</tr>
<%--												<tr>--%>
<%--													<th class="text-right essential-item">아이콘버튼</th>--%>
<%--													<td>--%>
<%--														<div class="form-check form-check-inline">--%>
<%--															<input class="form-check-input iclassYn" type="radio" name="icon_btn_yn" value="Y">--%>
<%--															<label class="form-check-label">Y</label>--%>
<%--														</div>--%>
<%--														<div class="form-check form-check-inline">--%>
<%--															<input class="form-check-input iclassYn" type="radio" name="icon_btn_yn" value="N">--%>
<%--															<label class="form-check-label">N</label>--%>
<%--														</div>--%>
<%--													</td>--%>
<%--												</tr>--%>
<%--												<tr>--%>
<%--													<th class="text-right essential-item">아이콘 클래스</th>--%>
<%--													<td>--%>
<%--														<select class="form-control essential-bg" id="i_class" name="i_class" alt="아이콘 클래스">--%>
<%--															<option value="">- 선택 -</option>--%>
<%--															<option value="icon-comment-edit btn btn-link">icon-comment-edit btn btn-link</option>--%>
<%--															<option value="icon-comment-delete btn btn-link">icon-comment-delete btn btn-link</option>--%>
<%--														</select>--%>
<%--													</td>--%>
<%--												</tr>--%>
												<tr>
													<th class="text-right essential-item">크기 클래스</th>
													<td>
														<select class="form-control essential-bg" id="size_class" name="size_class" alt="크기 클래스">
															<option value="">- 선택 -</option>
															<option value="btn">basic</option>
															<option value="btn btn-xs">x-small</option>
															<option value="btn btn-sm">small</option>
															<option value="btn btn-lg">large</option>
															<option value="btn btn-xl">x-large</option>
														</select>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">버튼 클래스</th>
													<td>
														<select class="form-control essential-bg" id="btn_class" name="btn_class" alt="버튼 클래스">
															<option value="">- 선택 -</option>
															<option value="btn-primary">파란색 배경에 흰색 글씨</option>
															<option value="btn-secondary">빨간색 배경에 흰색 글씨</option>
															<option value="btn-neutral">회색 배경에 흰색 글씨</option>
															<option value="btn-green">초록색 배경에 흰색 글씨</option>
															<option value="btn-orange">주황색 배경에 흰색 글씨</option>
															<option value="btn-yellow">노란색 배경에 흰색 글씨</option>
															<option value="btn-black">검은색 배경에 흰색 글씨</option>
															<option value="btn-primary-outline">파란색 태두리에 파란색 글씨</option>
															<option value="btn-secondary-outline">빨간색 태두리에 빨간색 글씨</option>
															<option value="btn-neutral-outline">회색 태두리에 회색 글씨</option>
															<option value="btn-green-outline">초록색 태두리에 초록색 글씨</option>
															<option value="btn-white-outline">하얀색 태두리에 하얀색 글씨</option>
															<option value="btn-orange-outline">주황색 태두리에 주황색 글씨</option>
															<option value="btn-yellow-outline">노란색 태두리에 노란색 글씨</option>
															<option value="btn-black-outline">검은색 태두리에 검은색 글씨</option>
														</select>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">JS명령어</th>
													<td>
														<input type="text" class="form-control essential-bg" id="js_name" name="js_name" alt="JS명령어">
													</td>
												</tr>
												<tr>
													<th class="text-right">비고</th>
													<td>
														<textarea class="form-control" style="height: 50px;" id="remark" name="remark"></textarea>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">사용여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="Y" alt="사용여부">
															<label class="form-check-label">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="N">
															<label class="form-check-label">N</label>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">결재관련여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="appr_yn" value="Y" alt="결재관련여부 ">
															<label class="form-check-label">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="appr_yn" value="N">
															<label class="form-check-label">N</label>
														</div>
													</td>
												</tr>
												<tr style="height: 51px;">
													<th class="text-right"><a href="javascript:void(0)" class="btn btn-default" style="vertical-align: middle;" onclick="javascript:fnPreview();">미리보기</a></th>
													<td>
														<div id="preview"></div>
													</td>
												</tr>											
											</tbody>
										</table>
									</div>
									<!-- /폼테이블 -->
									<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
									<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
								<!-- /버튼정보 -->									
							</div>					
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>
<input type="hidden" id="display_prefix" name="display_prefix">
<input type="hidden" id="display_postfix" name="display_postfix">	
</form>
</body>
</html>