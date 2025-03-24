<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드 > 고장부위코드관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-16 10:48:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
	});
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			editable : true,
			// 수정 표시
			showStateColumn : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField : "group_code",
				visible : false
			},
			{
				headerText: "고장원인코드",
				dataField: "code",
				width : "15%",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer", 
					onlyNumeric : true,
					allowPoint : false,  // 소수점( . ) 도 허용할지 여부
					// 코드값 벨리데이션 (중복체크, 자리수)
					auiGrid : "#auiGrid",
					minlength : 2,
					validator : AUIGrid.commonValidator
				}				
			},
			{
				headerText: "고장원인명",
				dataField: "code_name",
				width : "61%",
				editable : true,
				style : "aui-left aui-editable"
			},
			{
				headerText: "정렬순서",
				dataField: "sort_no",
				width : "8%",
				dataType : "numeric",
				editable : true,
				style : "aui-center aui-editable",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				}
			},
			{ 
				headerText : "사용여부", 
				dataField : "use_yn", 
				width : "8%", 
				editable : true,
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "8%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);		
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
						}
					},
					visibleFunction   :  function(rowIndex, columnIndex, value, item, dataField ) {
						// 삭제버튼은 행 추가시에만 보이게 함
						if(AUIGrid.isAddedById("#auiGrid",item._$uid)) {
						  	return true;
						}
						else {
						  	return false;
						}	
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			if (event.dataField == "code") {
				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					return false;
				}
			}
		});
		
		AUIGrid.bind(auiGrid, "addRow", function( event ) {
			fnUpdateCnt();
		});
		AUIGrid.bind(auiGrid, "removeRow", function( event ) {
			fnUpdateCnt();
		});
		
		$("#auiGrid").resize();
	}
	
	function fnUpdateCnt() {
		var cnt = AUIGrid.getGridData(auiGrid).length;
		$("#total_cnt").html(cnt);
	}
	
	// 저장
	function goSave() {
 		if (fnChangeGridDataCnt(auiGrid) == 0){
			alert("변경된 데이터가 없습니다.");
			return false;
		};
		if (fnCheckGridEmpty(auiGrid) === false){
			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}
		
		var frm = fnChangeGridDataToForm(auiGrid);
		$M.goNextPageAjaxSave("/comm/comm040102/save", frm, {method : 'POST'},
			function(result) {
				if(result.success) {
					AUIGrid.removeSoftRows(auiGrid);
					AUIGrid.resetUpdatedItems(auiGrid);
					$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);		
					goSearch();
				};
			}
		);
	}
	
	// 행추가
	function fnAdd() {
		var params = AUIGrid.getGridData(auiGrid);
		if (params.length == 0) {
			alert("고장현상 조회 후 행 추가를 진행해주세요.");
			return false;
		}

		if(fnCheckGridEmpty(auiGrid)) {
			var item = new Object();
			item.group_code = "BREAK_REASON";
    		item.code = "";
    		item.code_name = "";
    		item.sort_no = null;
    		item.use_yn = "Y";
    		AUIGrid.addRow(auiGrid, item, 'last');
		}	
	}	
	
	// 조회
	function goSearch() {
		var param = {
				s_code : $M.getValue("s_code"),
				s_code_name : $M.getValue("s_code_name"),
				s_sort_key : "sort_no",
				s_sort_method : "asc"
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
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
		var field = ["s_code", "s_code_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["code", "code_name", "sort_no","use_yn"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
			<div class="content-box" style="width : 60%;">
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap mt10">				
						<table class="table table-fixed">
							<colgroup>
								<col width="85px">
								<col width="120px">								
								<col width="75px">
								<col width="120px">		
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>고장원인코드</th>
									<td>
										<input type="text" class="form-control" name="s_code">
									</td>	
									<th>고장원인명</th>
									<td>
										<input type="text" class="form-control" name="s_code_name">
									</td>
									<td>
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
						<h4>고장현상원인코드 조회결과</h4>
							<div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
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