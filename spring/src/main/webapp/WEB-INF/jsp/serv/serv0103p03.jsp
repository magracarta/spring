<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 공구관리
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-17 15:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	var gridRowIndex;
	
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
				showRowNumColumn: true
		};
		var columnLayout = [
			{ 
				dataField : "svc_tool_seq", 
				visible : false
			},
			{ 
				headerText : "공구명", 
				dataField : "tool_name", 
				style : "aui-left  aui-editable",
				required : true,
				editable : true,
				width : "20%"
			},
			{ 
				headerText : "정렬순서", 
				dataField : "sort_no", 
				style : "aui-center aui-editable",
				required : true,
				editable : true,
				width : "7%"
			},			
			{
				headerText : "이미지", 
				dataField : "file_seq", 
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						
						//이미지가 있는경우 상세보기 , 없는경우 업로드 하기 ( 파일업로드 공통모듈)
						gridRowIndex = event.rowIndex;
												
						if(event.item.file_seq > 0) {
							fnFileDragAndDrop(event.item.file_seq);
						}
						else {
							fnFileDragAndDrop();
						}					
					},
					
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					
					if( value == "" || value == 0 ){
						return '첨부'
					}
					else {
						return '보기'
					}					
					
				},
				style : "aui-center",
				width : "8%",
				editable : false
				
			},
			{ 
				headerText : "사용여부", 
				dataField : "use_yn", 
				style : "aui-center",
				width : "10%",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			},
			{ 
				headerText : "등록자", 
				dataField : "reg_mem_name", 
				width : "10%",
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "등록일", 
				dataField : "reg_dt", 
				dataType : "date", 
				width : "15%",
				formatString : "yyyy-mm-dd",
				editable : false
			},			
			{ 
				headerText : "변경자", 
				dataField : "upt_mem_name", 
				width : "10%",
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "변경일시", 
				dataField : "upt_dt", 
				dataType : "date", 
				width : "20%",
				formatString : "yy-mm-dd HH:MM:ss",
				editable : false
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		$("#auiGrid").resize();
		
		goSearch();
		
	}
	
	// 조회
	function goSearch() {
		
		var param = {
				
				s_tool_name : $M.getValue("s_tool_name"),
				s_sort_key : "sort",
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
	
	// 행추가
	function fnAdd() {					

   		var item = new Object();
   		item.svc_tool_seq = "";	
   		item.tool_name = "";
   		item.sort_no = "";
   		item.file_seq = "";
   		item.use_yn = "Y";

		AUIGrid.addRow(auiGrid, item, 'first');
		
	}
	
	// 파입업로드(드래그앤드랍)
	function fnFileDragAndDrop(fileSeq) {
		var param = {					
		   'upload_type': 'SERVICE',
		   // 'max_width': '',
		   // 'max_height': '',
		   'pixel_limit_yn': '',
		   'max_size': '1000',
		   'size_limit_yn': '',
		   'file_type': 'img',
		   'file_seq': fileSeq
		};
		
		openFileUploadPanel('setSaveFileInfo', $M.toGetParam(param));
	} 
	
	function setSaveFileInfo(result) {
		
		AUIGrid.updateRow(auiGrid, { "file_seq" : result.file_seq }, gridRowIndex);
	}
	
	
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validation(auiGrid);
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
		
		var frm = fnChangeGridDataToForm(auiGrid , 'N');	    			
		console.log(frm);
		
		$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
			function(result) {
				if(result.success) {

					location.reload();
				};
			}
		);
	}
	
	// 닫기
    function fnClose() {
    	opener.${inputParam.parent_js_name}();
    	window.close();
    }
	

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	 
<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="150px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>공구명</th>
							<td>
								<input type="text" class="form-control" id="s_tool_name" name="s_tool_name" >
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
					</div>
				</div>
			</div>
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 320px;"></div>
			<div class="btn-group mt10">
				<div class="left">
						총 <strong class="text-primary"  id="total_cnt" >0</strong>건
				</div>		
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>