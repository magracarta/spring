<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 렌탈비관리-어태치먼트 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true,
				enableFilter : true
			};
			var columnLayout = [
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{ 
					headerText : "부품번호",
					dataField : "part_no",
					editable : false,
					width : "100",
					minWidth : "100",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					editable : false,
					width : "100",
					minWidth : "45",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				// {
				// 	headerText : "메이커",
				// 	dataField : "maker_name",
				// 	editable : false,
				// 	width : "85",
				// 	minWidth : "45",
				// 	labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
				// 	     return value == null ? "공용" : value;
				// 	},
				// 	style : "aui-center",
				// 	filter : {
				// 		showIcon : true
				// 	}
				// },
				{
					headerText : "장비기종",
					dataField : "machine_type_name",
					editable : false,
					width : "85",
					minWidth : "45",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "장비규격",
					dataField : "machine_type_name",
					editable : false,
					width : "200",
					minWidth : "150",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "적용모델명",
					dataField : "machine_name",	
					editable : false,
					width : "300",
					minWidth : "300",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return value == "DUMMY" ? "공용" : value; 
					},
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},			
				{
					headerText : "적용일",
					dataField : "price_dt",
					editable : false,
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "85", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},					
				{
					headerText : "1일", 
					dataField : "rental1_price", 
					dataType : "numeric",
					width : "85", 
					minWidth : "45",
					style : "aui-right  aui-editable",
					editable : true,
					required : true,
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "7일", 
					dataField : "rental7_price", 
					dataType : "numeric",
					width : "85", 
					minWidth : "45",
					style : "aui-right  aui-editable",
					editable : true,
					required : true,
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "15일", 
					dataField : "rental15_price", 
					dataType : "numeric",
					width : "85", 
					minWidth : "45",
					style : "aui-right  aui-editable",
					editable : true,
					required : true,
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "30일", 
					dataField : "rental30_price", 
					dataType : "numeric",
					width : "85", 
					minWidth : "45",
					style : "aui-right  aui-editable",
					editable : true,
					required : true,
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "85", 
					minWidth : "45",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					},
					filter : {
						showIcon : true
					}
				}				
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		
		function enter(fieldObj) {
			var field = ["s_machine_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 조회
		function goSearch() {
			var param = {
				// "s_maker_cd" : $M.getValue("s_maker_cd")
				//, "s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
				// , "s_machine_name" : $M.getValue("s_machine_name")
				"s_use_yn" : $M.getValue("s_use_yn")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}
	
		// 저장
		function goSave() {
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			if(0 == gridFrm.length) {
				alert("변경된 값이 없습니다.");
				return false;
			}
			$M.goNextPageAjaxSave(this_page + '/save', gridFrm , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					}
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
			<div class="contents" >
	<!-- 기본 -->					
				<div class="search-wrap">				
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="130px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
<%--								<th>메이커</th>--%>
<%--								<td>--%>
<%--									<select class="form-control" id="s_maker_cd" name="s_maker_cd">--%>
<%--										<option value="">- 전체 -</option>--%>
<%--										<c:forEach items="${codeMap['MAKER']}" var="item">--%>
<%--											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">--%>
<%--												<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>--%>
<%--											</c:if>--%>
<%--										</c:forEach>--%>
<%--									</select>--%>
<%--								</td>--%>
<%--								<th>모델</th>--%>
<%--								<td>--%>
<%--									<div class="form-row inline-pd">							--%>
<%--										<div class="col-12">--%>
<%--											<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">--%>
<%--										</div>								--%>
<%--									</div>--%>
<%--								</td>	--%>
								<th>사용구분</th>
								<td>
									<select class="form-control" id="s_use_yn" name="s_use_yn">
										<option value="Y">사용</option>
										<option value="N">미사용</option>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()"  >조회</button>
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
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
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