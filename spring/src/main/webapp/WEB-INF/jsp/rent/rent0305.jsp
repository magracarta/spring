<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 렌탈신차감가관리 > null > null
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
				headerText : "메이커",
				dataField : "maker_name",
				width : "65", 
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				width : "100", 
				minWidth : "90",
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				}
			},

			{
				headerText : "감가",
				dataField : "reduce_price", 		
				style : "aui-right  aui-editable",
				dataType : "numeric",
				width : "70", 
				minWidth : "60",
				formatString : "#,##0",
				editable : true,
				required : true,
				editRenderer : {
				    type : "InputEditRenderer",
				    onlyNumeric : true,
		     	 	maxlength : 20,
			      	// 에디팅 유효성 검사
			      	validator : AUIGrid.commonValidator
				},
				filter : {
					showIcon : true
				}
			},			
			{
				headerText : "등록일시",
				dataField : "reg_date", 
				dataType : "date",
				formatString : "yy-mm-dd",
				width : "75", 
				minWidth : "65",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},					
			{
				headerText : "등록자", 
				dataField : "reg_mem_name", 		
				width : "65", 
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				width : "65", 
				minWidth : "60",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
				filter : {
					showIcon : true
				}
			},
			{
				dataField : "machine_plant_seq",
				visible : false
			},
			{
				dataField : "rental_reduce_new_seq",
				visible : false
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

	function goSearch() {
		var param = {
			"s_maker_cd" : $M.getValue("s_maker_cd")
			, "s_machine_name" : $M.getValue("s_machine_name")
			, "s_use_yn" : $M.getValue("s_use_yn")
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

	// 엑셀 다운로드
	function fnDownloadExcel() {
		// 제외항목
	 	var exportProps = {};
		fnExportExcel(auiGrid, "렌탈신차감가관리", exportProps);
	}
	

	// 저장
	function goSave() {
		var gridFrm = fnChangeGridDataToForm(auiGrid);
		if(0 == gridFrm.length) {
			alert("변경된 값이 없습니다.");
			return false;
		}
		for(var i in gridFrm) {
			try {
				var id = gridFrm[i].id;
				var val = gridFrm[i].value;
				if("reduce_price" == id) {
					if("" == val || null == val) {
						alert("감가는 필수 입력입니다.");
						return false;
					} else {
						break;
					}
				}
			} catch (e) {
				console.log(e);
			}
		}
		var msg = "해당하는 모든 렌탈장비의 감가가 변경되며, 변경된 감가정보가 이력에 등록됩니다.";
		$M.goNextPageAjaxMsg(msg, this_page + '/save', gridFrm , {method : 'POST'},
			function(result) {
				if(result.success) {
					console.log(result);
					alert("저장이 완료되었습니다. 영향을 받은 렌탈장비 개수는 "+$M.toNum(result.afftectedRmCnt)+"개 입니다. 해당 모델의 감가이력을 확인해주세요.");
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
			<div class="contents"   style="width : 60%;">
	<!-- 기본 -->					
				<div class="search-wrap">				
					<table class="table">
						<colgroup>							
							<col width="50px">
							<col width="75px">
							<col width="40px">
							<col width="160px">
							<col width="65px">
							<col width="65px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
												<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>모델</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
										</div>	
									</div>
								</td>	
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
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
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