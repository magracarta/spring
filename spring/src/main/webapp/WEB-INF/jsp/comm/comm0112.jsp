<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 문자템플릿관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGrid;
		
		$(document).ready(function() {
			createAUIGrid();
		});	
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				enableSorting : true,
				rowIdField : "sms_template_seq", 
				rowIdTrustMode : true,
				showStateColumn : true,
				editable : true,
			};
			var columnLayout = [
				{ 
					dataField : "sms_template_seq", 
					visible : false, 
				},
				{ 
					headerText : "적용구분코드", 
					dataField : "sms_template_type_name", 
					width : "8%", 
					editable : false,
				},
				{ 
					headerText : "템플릿명", 
					dataField : "template_name", 
					style : "aui-left aui-popup",
					width : "15%", 
					editable : false,
				},
				{ 
					headerText : "내용", 
					dataField : "template_text", 
					style : "aui-left",
					editable : false,
				},
				{ 
					headerText : "적용센터 수", 
					dataField : "center_cnt", 
					width : "8%", 
					editable : false,
					dataType : "numeric"
				},
				{ 
					headerText : "적용메이커 수", 
					dataField : "maker_cnt", 
					width : "8%", 
					editable : false,
					dataType : "numeric"
				},
				{ 
					headerText : "적용모델 수", 
					dataField : "model_cnt", 
					width : "8%", 
					editable : false,
					dataType : "numeric"
				},
				{ 
					headerText : "작성자", 
					dataField : "mem_name", 
					editable : false,
					width : "6%", 
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "8%", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},
				{ 
					headerText : "정렬순서", 
					dataField : "sort_no", 
					width : "8%", 
					style : "aui-editable",
					dataType : "numeric",
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false // 소수점(.) 입력 가능 설정
					},
					editable : true,
				},
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'template_name'){
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=700, left=0, top=0";
					var param = {
							sms_template_seq : event.item.sms_template_seq
					}
					$M.goNextPage('/comm/comm0112p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
		
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			var param = {
				s_sms_template_type_cd : $M.getValue("s_sms_template_type_cd"),
				s_use_yn : $M.getValue("s_use_yn"),
				s_template_name : $M.getValue("s_template_name"),
				s_sort_key : "sort_no asc nulls last, reg_date",
				s_sort_method : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function enter(fieldObj) {
			var field = [ "s_template_name" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function goNew() {
			$M.goNextPage("/comm/comm011201");
		}
		
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page+"/modify", frm, {method : 'post'},
				function(result) {
					if(result.success) {
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "문자템플릿관리", exportProps);
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
<!-- 기본 -->					
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="110px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="150px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>적용범위</th>
									<td>
										<select class="form-control" id="s_sms_template_type_cd" name="s_sms_template_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap.SMS_TEMPLATE_TYPE}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>사용여부</th>
									<td>
										<select class="form-control" id="s_use_yn" name="s_use_yn">
											<option value="">- 전체 -</option>
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td>
									<th>템플릿명</th>
									<td>
										<input type="text" class="form-control" id="s_template_name" name="s_template_name">
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>				
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>