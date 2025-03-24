<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS리스트관리 > null > 메이커
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-03 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});

		var isValid = true;

		function fnClose() {
			window.close();
		}

		function fnAdd() {
			var obj = new Object();
			obj.maker_cd = "이 값은 자동증가합니다.";
			obj.maker_name = "";
			obj.add = true;
			AUIGrid.addRow(auiGrid, obj, 'last');
		}
		function goSave(row) {
			var item = row.item;
			if (item.maker_name == "") {
				AUIGrid.showToastMessage(auiGrid, row.rowIndex, 1, "메이커명은 필수입니다.");
				return false;
			}
			var param = {
				"maker_name" : item.maker_name,
			};
			$M.goNextPageAjaxMsg("저장 성공 후, 클릭 하면 앞페이지에 반영됩니다.",this_page + "/save", $M.toGetParam(param), {method : 'post'},
				function(result) {
					if(result.success) {
						console.log(result);
						AUIGrid.updateRow(auiGrid, { "add" : "", "maker_cd" : result.maker_cd}, row.rowIndex);
					};
				}
			);
		}

		function createAUIGrid() {
			var gridPros = {
					// rowIdField 설정
				rowIdField : "_$uid",
				// rowNumber
				showRowNumColumn: false,
				enableFilter :true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
// 				wrapSelectionMove : false,
				editable : true,
			};
			var columnLayout = [
				{
					headerText : "메이커코드",
					dataField : "maker_cd",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커명",
					dataField : "maker_name",
					style : "aui-center",
					editable : true,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "추가",
					dataField : "add",
					width : "10%",
					editable : false,
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							goSave(event);
						},
						visibleFunction :  function(rowIndex, columnIndex, value, item, dataField ) {
							// 행 아이템의 name 이 Anna 라면 버튼 표시 하지 않음
					       if(item.add == true) {
					              return true;
					        }
					        return false;
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
							if (value != null) {
								return '저장'
							}
					},
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${makerList});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.item.add == true) {
					return false;
				}
				var openByRowId = AUIGrid.isItemOpenByRowId(event.pid, event.rowIdValue);
				if((event.treeIcon == false && openByRowId == true) || openByRowId == undefined) {
					try {
						// 23.03.07 정윤수 row 클릭할때마다 추가될 수 있도록 추가
						if("${inputParam.multi_yn}" == "Y"){
							if(opener.${inputParam.parent_js_name}(event.item) != undefined) {
								alert(opener.${inputParam.parent_js_name}(event.item));
								return false;
							}
						} else {
							opener.${inputParam.parent_js_name}(event.item);
							window.close();
						}
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					};
				}
			});
		}

		function naturalSort(ar, index){
		    var L= ar.length, i, who, next,
		    isi= typeof index== 'number',
		    rx=  /(\.\d+)|(\d+(\.\d+)?)|([^\d.]+)|(\.(\D+|$))/g;
		    function nSort(aa, bb){
		        var a= aa[0], b= bb[0], a1, b1, i= 0, n, L= a.length;
		        while(i<L){
		            if(!b[i]) return 1;
		            a1= a[i];
		            b1= b[i++];
		            if(a1!== b1){
		                n= a1-b1;
		                if(!isNaN(n)) return n;
		                return a1>b1? 1: -1;
		            }
		        }
		        return b[i]!= undefined? -1: 0;
		    }
		    for(i= 0; i<L; i++){
		        who= ar[i];
		        next= isi? ar[i][index] || '': who;
		        ar[i]= [String(next).toLowerCase().match(rx), who];
		    }
		    ar.sort(nSort);
		    for(i= 0; i<L; i++){
		        ar[i]= ar[i][1];
		    }
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
			<div class="title-wrap">			
				<h4 class="primary">메이커구분목록</h4>	
				<button type="button" class="btn btn-default" onclick="javascript:fnAdd()">추가</button>			
			</div>
			<div id="procent_dialog"></div>
			<div style="margin-top: 5px; height: 350px; " id="auiGrid"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>