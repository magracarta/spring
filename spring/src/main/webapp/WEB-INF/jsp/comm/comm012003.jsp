<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			rowIdTrustMode : true,
			showRowNumColumn: true,
			editable : true,
			enableFilter :true,
			showStateColumn : true
		};
		
		var columnLayout = [
			{
				headerText : "코드",
				dataField : "biz_code",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				},
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 4,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
			},
			{
				headerText : "월 수당",
				dataField : "mon_benefit_amt",
				width : "130",
				style : "aui-right aui-editable",
				dataType : "numeric",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : true,
			},
			{
				headerText : "연 수당",
				dataField : "year_benefit_amt",
				width : "150",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
					// 수량 * 단가 계산
					return ( item.mon_benefit_amt * 12 ); 
				}
			},
			{
				headerText : "내용",
				dataField : "remark",
				width : "450",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText : "정렬순서",
				dataField : "sort_no",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				width : "80",
				style : "aui-center",
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
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			if(event.dataField == "biz_code") {
				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "새로 추가된 행만 수정이 가능합니다.");
					}, 1);
					return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
				}
			}
		});
		
		AUIGrid.bind(auiGrid, "cellEditEndBefore", function (event) {
			if(event.dataField == "biz_code") {
				var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);	
				if (isUnique == false && event.value != "" && event.oldValue != event.value) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "업무레벨이 중복됩니다.");
					}, 1);
					return "";
				} else {
					if (event.value == "") {
						return event.oldValue;							
					}
				}
			}
		});
	}
	
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
	    		item.biz_code = "",
	    		item.mon_benefit_amt = "",
	    		item.year_benefit_amt = "",
	    		item.remark = "",
	    		item.sort_no = "",
	    		item.use_yn = "Y",
	    		AUIGrid.addRow(auiGrid, item, 'last');
		}
	}
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["biz_code", "mon_benefit_amt", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	function goSave() {
		if(fnCheckGridEmpty(auiGrid) == false) {
			return;
		}
		
		var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}
		
		var bizCodeArr = [];
		var monBenefitAmtArr = [];
		var remarkArr = [];
		var sortNoArr = [];
		var useYnArr = [];
		var bizCmdArr = [];
		
		for (var i = 0; i < addGridData.length; i++) {
			bizCodeArr.push(addGridData[i].biz_code);
			monBenefitAmtArr.push(addGridData[i].mon_benefit_amt);
			remarkArr.push(addGridData[i].remark);
			sortNoArr.push(addGridData[i].sort_no);
			useYnArr.push(addGridData[i].use_yn);
			bizCmdArr.push("C");
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			bizCodeArr.push(changeGridData[i].biz_code);
			monBenefitAmtArr.push(changeGridData[i].mon_benefit_amt);
			remarkArr.push(changeGridData[i].remark);
			sortNoArr.push(changeGridData[i].sort_no);
			useYnArr.push(changeGridData[i].use_yn);
			bizCmdArr.push("U");
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				biz_code_str : $M.getArrStr(bizCodeArr, option),
				mon_benefit_amt_str : $M.getArrStr(monBenefitAmtArr, option),
				remark_str : $M.getArrStr(remarkArr, option),
				sort_no_str : $M.getArrStr(sortNoArr, option),
				use_yn_str : $M.getArrStr(useYnArr, option),
				cmd_str : $M.getArrStr(bizCmdArr, option),
		}
		
		$M.goNextPageAjaxSave("/comm/comm012003/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("저장이 완료되었습니다.");
	    			goSearch();
				}
			}
		);
	}
	
	function goSearch() {
		var param = {
			s_biz_code : $M.getValue("s_biz_code")
		};
			
		$M.goNextPageAjax("/comm/comm012003/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);	
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_biz_code"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
		<div class="content-box">
			<div class="contents">

<!-- 메인 타이틀 -->
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="150px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>코드명</th>
									<td>
										<input type="text" class="form-control" id="s_biz_code" name="s_biz_code">
									</td>		
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<div class="btn-group">
						<h4>조회결과</h4>
							<div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 440px;" ></div>

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
<!-- /contents 전체 영역 -->		
</form>
</body>
</html>